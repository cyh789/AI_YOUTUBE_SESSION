import { mkdir, readFile, writeFile } from "node:fs/promises";
import path from "node:path";
import { GoogleGenAI } from "@google/genai";
import sharp from "sharp";

function parseArgs(argv) {
  const args = {};

  for (let index = 0; index < argv.length; index += 1) {
    const token = argv[index];

    if (!token.startsWith("--")) {
      continue;
    }

    const key = token.slice(2);
    const next = argv[index + 1];

    if (!next || next.startsWith("--")) {
      args[key] = "true";
      continue;
    }

    args[key] = next;
    index += 1;
  }

  return args;
}

async function loadEnvFile() {
  const envPath = path.resolve(".env");

  try {
    const raw = await readFile(envPath, "utf8");
    const parsed = {};

    for (const line of raw.split(/\r?\n/)) {
      const trimmed = line.trim();

      if (!trimmed || trimmed.startsWith("#")) {
        continue;
      }

      const separatorIndex = trimmed.indexOf("=");
      if (separatorIndex === -1) {
        continue;
      }

      const key = trimmed.slice(0, separatorIndex).trim();
      let value = trimmed.slice(separatorIndex + 1).trim();

      if (
        (value.startsWith('"') && value.endsWith('"')) ||
        (value.startsWith("'") && value.endsWith("'"))
      ) {
        value = value.slice(1, -1);
      }

      parsed[key] = value;
    }

    return parsed;
  } catch {
    return {};
  }
}

function timestampLabel() {
  const now = new Date();
  const parts = [
    now.getFullYear(),
    String(now.getMonth() + 1).padStart(2, "0"),
    String(now.getDate()).padStart(2, "0"),
    String(now.getHours()).padStart(2, "0"),
    String(now.getMinutes()).padStart(2, "0"),
    String(now.getSeconds()).padStart(2, "0"),
  ];

  return `${parts[0]}${parts[1]}${parts[2]}-${parts[3]}${parts[4]}${parts[5]}`;
}

function sanitizeBaseName(value) {
  return value.replace(/[<>:"/\\|?*\u0000-\u001F]/g, "-").replace(/\s+/g, "-");
}

function collectParts(response) {
  return response?.candidates?.flatMap((candidate) => candidate?.content?.parts ?? []) ?? [];
}

async function toPngBuffer(buffer, mimeType) {
  if (!mimeType || mimeType === "image/png") {
    return buffer;
  }

  return sharp(buffer).png().toBuffer();
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  const envFile = await loadEnvFile();
  const apiKey =
    process.env.GEMINI_API_KEY ||
    process.env.GOOGLE_API_KEY ||
    envFile.GEMINI_API_KEY ||
    envFile.GOOGLE_API_KEY;
  const insecure = args.insecure === "true";

  if (insecure) {
    process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0";
  }

  if (!apiKey) {
    console.error("GEMINI_API_KEY 또는 GOOGLE_API_KEY 를 찾을 수 없습니다. .env 파일을 확인하세요.");
    process.exit(1);
  }

  const prompt = args.prompt;

  if (!prompt) {
  console.error('프롬프트가 필요합니다. 예: node gemini/gemini-image-generate.mjs --prompt "파란 배경의 미니멀 제품 포스터"');
    process.exit(1);
  }

  const model = args.model || "gemini-2.5-flash-image";
  const aspectRatio = args["aspect-ratio"] || "16:9";
  const imageSize = args["image-size"] || "2K";
  const outputDir = path.resolve(args["output-dir"] || "output");
  const outputFile =
    args["output-file"] ||
    `gemini-generated-${sanitizeBaseName(timestampLabel())}.png`;

  await mkdir(outputDir, { recursive: true });

  const ai = new GoogleGenAI({ apiKey });
  const response = await ai.models.generateContent({
    model,
    contents: prompt,
    config: {
      responseModalities: ["Image"],
      imageConfig: {
        aspectRatio,
        imageSize,
      },
    },
  });

  const parts = collectParts(response);
  const imagePart = parts.find((part) => part.inlineData?.data);

  if (!imagePart) {
    console.error("응답에서 이미지 데이터를 찾지 못했습니다.");

    for (const part of parts) {
      if (part.text) {
        console.error(`텍스트 응답: ${part.text}`);
      }
    }

    process.exit(1);
  }

  const outputPath = path.join(outputDir, outputFile.endsWith(".png") ? outputFile : `${outputFile}.png`);
  const sourceBuffer = Buffer.from(imagePart.inlineData.data, "base64");
  const buffer = await toPngBuffer(sourceBuffer, imagePart.inlineData?.mimeType);

  await writeFile(outputPath, buffer);

  console.log("이미지 생성을 완료했습니다.");
  console.log(`모델: ${model}`);
  console.log(`출력 파일: ${outputPath}`);

  if (imagePart.inlineData?.mimeType && imagePart.inlineData.mimeType !== "image/png") {
    console.log(`원본 MIME 타입 ${imagePart.inlineData.mimeType} 을 PNG로 변환해 저장했습니다.`);
  }
}

main().catch((error) => {
  console.error("Gemini 이미지 생성 중 오류가 발생했습니다.");

  if (error?.cause?.code === "SELF_SIGNED_CERT_IN_CHAIN") {
    console.error("현재 네트워크 환경의 자체 서명 인증서 때문에 HTTPS 요청이 차단되었습니다.");
    console.error("임시로 진행하려면 --insecure true 옵션을 사용하세요.");
  }

  console.error(error);
  process.exit(1);
});
