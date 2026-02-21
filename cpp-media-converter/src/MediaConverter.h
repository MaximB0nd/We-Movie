#include <stdexcept>
#include <string>
#include <filesystem>
#include <cstdlib>
#include <iostream>
#include <vector>
#include <exception>

namespace fs = std::filesystem;

class MediaConverter 
{
private:

    const std::string ffmpeg_basic_command = "ffmpeg -i";
    const std::string format = ".m3u8";

    bool contains(const std::string &str, char target) 
    {
        for (const auto& c: str) 
        {
            if (c == target) return true;
        }
        return false;
    }

    std::vector<std::string> analyse(const std::string& path_to_entry) 
    {
        std::vector<std::string> result;
        fs::path path_to_media = path_to_entry;
        try 
        {    
            for (const auto& entry : fs::directory_iterator(path_to_media)) 
            {
                std::cout << entry.path().string() << std::endl;
                if (contains(entry.path().string(), '.')) 
                {
                    result.push_back(entry.path().string());
                }
            }

        } 
        catch (const fs::filesystem_error& e) 
        {
            std::cerr << "Filesystem error: " << e.what() << std::endl; 
        }
        std::cout << "Found: " << result.size() << " media objects" << std::endl;
        return result; 
    }

    std::vector<std::string> basic_splitter(const std::string &str, char splitter) 
    {
        std::vector<std::string> result;
        std::string buffer{""};
        for (const auto &c: str) 
        {
            if (c == splitter) 
            {
                result.push_back(buffer);
                std::cout << "Words: " << buffer << "\n";
                buffer.clear();
            } else buffer += c;
        }
        if (result.size() == 0) throw std::logic_error("Error: splitter buffer free"); 
        else return result;
    }

public:
	
    MediaConverter() {};
    ~MediaConverter() {};

	void run(const std::string& media_path) 
    {
        std::vector<std::string> media = analyse(media_path); 
        fs::path path_to_new_directory = media_path + '/' + "converted";
        fs::create_directory(path_to_new_directory);
       
		for (const auto &path_to_media : media) 
        {
            bool is_begin = true;
            
            auto path_to_media_fixed = path_to_media.substr(1, path_to_media.size());
            path_to_media_fixed += '/';
            std::cout << "Before substr: " << path_to_media << "\n";
            std::cout << "After substr: " << path_to_media_fixed << "\n";
            std::cout << "First splitting" << "\n";
            std::string f_media_name = *(basic_splitter(path_to_media_fixed, '/').end() - 1); 
            std::cout << "Second splitting with media_name: " << f_media_name << "\n";
            std::string media_name = (*basic_splitter(f_media_name, '.').begin());

            std::string final_media_name = path_to_new_directory.string() + "/" + media_name + "." + format;
            std::string full_ffmpeg_command = ffmpeg_basic_command + " " + path_to_media + " " +  final_media_name;

            std::system(full_ffmpeg_command.c_str());
        } 
	}
};
