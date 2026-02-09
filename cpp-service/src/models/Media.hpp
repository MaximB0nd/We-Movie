#ifndef H_MEDIA_CLASS
#define H_MEDIA_CLASS

#include <cstddef>
#include <memory>
#include <stdexcept>
#include <string>

class Media {

public:
  Media(std::shared_ptr<std::string> media_token,
        std::shared_ptr<int> media_length_sec,
        std::shared_ptr<std::string> media_name,
        std::shared_ptr<std::string> media_hls_link,
        std::shared_ptr<std::string> media_category)
      : media_token_(std::move(media_token)),
        media_length_sec_(std::move(media_length_sec)),
        media_name_(std::move(media_name)),
        media_hls_link_(std::move(media_hls_link)),
        media_category_(std::move(media_category)) {}
  ~Media() {}

  std::string get_media_token() {
    if (this->media_token_ != nullptr)
      return *(this->media_token_);
    else
      throw std::logic_error("Error: the \"media_token\" param is null");
  }

  int get_media_length_sec() {
    if (this->media_length_sec_ != nullptr)
      return *(this->media_length_sec_);
    else
      throw std::logic_error("Error: the \"media_length_sec\" param is null");
  }

  std::string get_media_name() {
    if (this->media_name_ != nullptr)
      return *(this->media_name_);
    else
      throw std::logic_error("Error: the \"media_length_sec\" param is null");
  }

  std::string get_media_hls_link() {
    if (this->media_hls_link_ != nullptr)
      return *(this->media_hls_link_);
    else
      throw std::logic_error("Error: the \"media_hls_link\" param is null");
  }

  void set_media_token(const std::shared_ptr<std::string> &media_token) {
    if (media_token != nullptr)
      this->media_token_ = media_token;
    else
      throw std::logic_error("Error: the \"media_token\" arg is null");
  }

  void set_media_length_sec(const std::shared_ptr<int> &media_length_sec) {
    if (media_length_sec != nullptr)
      this->media_length_sec_ = media_length_sec;
    else
      throw std::logic_error("Error: the \"media_length_sec\" arg is null");
  }

  void set_media_name(const std::shared_ptr<std::string> &media_name) {
    if (media_name != nullptr)
      this->media_name_ = media_name;
    else
      throw std::logic_error("Error: the \"media_name\" arg is null");
  }

  void set_media_hls_link(const std::shared_ptr<std::string> &media_hls_link) {
    if (media_hls_link != nullptr)
      this->media_hls_link_ = media_hls_link;
    else
      throw std::logic_error("Error: the \"media_hls_link\" arg is null");
  }

private:
  std::shared_ptr<std::string> media_token_;
  std::shared_ptr<int> media_length_sec_;
  std::shared_ptr<std::string> media_name_;
  std::shared_ptr<std::string> media_hls_link_;
  std::shared_ptr<std::string> media_category_;
};

#endif
