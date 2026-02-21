#include "src/MediaConverter.h"

#include <memory>

int main(int argc, char* argv[]) 
{
    std::unique_ptr<MediaConverter> M_CONV = std::make_unique<MediaConverter>();
    std::string path = argv[1];
    M_CONV->run(path);
    return 0;
}
