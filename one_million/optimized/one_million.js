const prefix = "Hello, this is iteration number: ";
const CHUNK_SIZE = 10000;
let chunk = "";

for (let i = 0; i < 1000000; i++) {
	chunk += prefix + i + "\n";
	if (i % CHUNK_SIZE === CHUNK_SIZE - 1) {
		process.stdout.write(chunk);
		chunk = "";
	}
}
if (chunk.length > 0) {
	process.stdout.write(chunk);
}
