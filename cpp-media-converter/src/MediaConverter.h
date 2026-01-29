#include <string>
#include <filesystem>
#include <cstdlib>
#include <iostream>

namespace fs = std::filesystem;

class MediaConverter {
private:
	std::string ffmpeg_basic_command = "ffmpeg -i";
public:
	MediaConverter() {};
	void run(const std::string& media_path,
		 const std::string& path_to_save) {
		std::string converted_media_name("");
		for (char c : media_path) {
			if (c == '.') {
				break;
			} else converted_media_name += c;
		}
		std::string converted_media_name_full =
			converted_media_name + ".m3u8";
		std::string ffmpeg_command = ffmpeg_basic_command + " " +
			media_path + " " + converted_media_name_full;
		std::system("ffmpeg -i");
	}
}
