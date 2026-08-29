#include <iostream>
#include <vector>
#include <string>

int main() {
	std::ios_base::sync_with_stdio(false);
	std::cin.tie(nullptr);

	constexpr size_t BUF_SIZE = 64 * 1024;
	char buffer[BUF_SIZE];
	size_t pos = 0;
	const std::string_view prefix = "Hello, this is iteration number: ";

	for (int n = 0; n < 1000000; ++n) {
		if (pos + prefix.size() + 12 > BUF_SIZE) {
			std::cout.write(buffer, pos);
			pos = 0;
		}
		std::copy(prefix.begin(), prefix.end(), buffer + pos);
		pos += prefix.size();

		char num_buf[10];
		int temp = n;
		int digits = 0;
		if (temp == 0) {
			num_buf[digits++] = '0';
		} else {
			while (temp > 0) {
				num_buf[digits++] = static_cast<char>('0' + (temp % 10));
				temp /= 10;
			}
		}
		for (int j = digits - 1; j >= 0; --j) {
			buffer[pos++] = num_buf[j];
		}
		buffer[pos++] = '\n';
	}
	if (pos > 0) {
		std::cout.write(buffer, pos);
	}
	return 0;
}
