#ifndef H_SESSION_CLASS
#define H_SESSION_CLASS

#include <memory>
#include <set>
#include <stdexcept>
#include <string>

#include "Media.hpp"
#include "User.hpp"

class Session {

public:
  Session(std::shared_ptr<std::string> session_token,
          std::shared_ptr<std::set<std::shared_ptr<User>>> session_users,
          std::shared_ptr<Media> session_media)
      : session_token_(std::move(session_token)),
        session_users_(std::move(session_users)),
        session_media_(std::move(session_media)) {}
  ~Session() {}

  std::string get_session_token() {
    if (this->session_token_ != nullptr)
      return *(this->session_token_);
    else
      throw std::logic_error("Error: the \"session_token\" param is null");
  }

  std::set<std::shared_ptr<User>> get_session_users() {
    if (this->session_users_ != nullptr)
      return *(this->session_users_);
    else
      throw std::logic_error("Error: the \"session_users\" param is null");
  }

  Media get_session_media() {
    if (this->session_media_ != nullptr)
      return *(this->session_media_);
    else
      throw std::logic_error("Error: the \"session_media\" param is null");
  }

  void set_session_token(const std::shared_ptr<std::string> &session_token) {
    if (session_token != nullptr)
      this->session_token_ = session_token;
    else
      throw std::logic_error("Error: the \"session_token\" arg is null");
  }

  void set_session_users(
      const std::shared_ptr<std::set<std::shared_ptr<User>>> &session_users) {
    if (session_users != nullptr)
      this->session_users_ = session_users;
    else
      throw std::logic_error("Error: the \"session_uesrs\" arg is null");
  }

  void set_sesssion_media(const std::shared_ptr<Media> &session_media) {
    if (session_media != nullptr)
      this->session_media_ = session_media;
    else
      throw std::logic_error("Error: the \"session_media\" arg is null");
  }

private:
  // std::shared_ptr<Chat> chat_;
  std::shared_ptr<std::string> session_token_;
  std::shared_ptr<std::set<std::shared_ptr<User>>> session_users_;
  std::shared_ptr<Media> session_media_;
};

#endif
