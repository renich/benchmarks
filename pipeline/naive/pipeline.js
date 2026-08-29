const FNV_OFFSET = 0xcbf29ce484222325n;
const FNV_PRIME  = 0x100000001b3n;
const MASK64     = 0xFFFFFFFFFFFFFFFFn;

function fnv1a(str) {
  let h = FNV_OFFSET;
  for (let i = 0; i < str.length; i++) {
    h = ((h ^ BigInt(str.charCodeAt(i))) * FNV_PRIME) & MASK64;
  }
  return h;
}

async function main() {
  const TOTAL = 100000;
  let totalChecksum = 0n;

  for (let i = 0; i < TOTAL; i++) {
    const payload = "task:item:" + i;
    totalChecksum = (totalChecksum + fnv1a(payload)) & MASK64;
  }

  console.log(`Pipeline complete: processed=${TOTAL}, checksum=${totalChecksum.toString()}`);
}

main();
