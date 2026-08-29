const FNV_OFFSET = 0xcbf29ce484222325n;
const FNV_PRIME  = 0x100000001b3n;
const MASK64     = 0xFFFFFFFFFFFFFFFFn;

function fnv1a_buf(buf, len) {
  let h = FNV_OFFSET;
  for (let i = 0; i < len; i++) {
    h = ((h ^ BigInt(buf[i])) * FNV_PRIME) & MASK64;
  }
  return h;
}

function main() {
  const TOTAL = 100000;
  let totalChecksum = 0n;
  const prefix = Buffer.from("task:item:", "ascii");
  const buf = Buffer.allocUnsafe(32);
  prefix.copy(buf);

  for (let i = 0; i < TOTAL; i++) {
    const s = i.toString();
    buf.write(s, prefix.length, "ascii");
    const len = prefix.length + s.length;
    totalChecksum = (totalChecksum + fnv1a_buf(buf, len)) & MASK64;
  }

  console.log(`Pipeline complete: processed=${TOTAL}, checksum=${totalChecksum.toString()}`);
}

main();
