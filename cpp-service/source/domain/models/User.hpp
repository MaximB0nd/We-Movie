#ifndef H_USER_CLASS
#define H_USER_CLASS

#include <memory>
#include <stdexcept>
#include <string>

#include "../values/Roles.hpp"

class User {

public:
  User(std::shared_ptr<std::string> user_token,
       std::shared_ptr<std::string> user_name, std::shared_ptr<ROLES> user_role)
      : user_token_(std::move(user_token)), user_name_(std::move(user_name)),
        user_role_(std::move(user_role)) {}

  ~User() {}

  std::string get_user_token() {
    if (this->user_token_ != nullptr)
      return *(this->user_token_);
    else
      throw std::logic_error("Error: the \"user_token\" param is null");
  }

  std::string get_user_name() {
    if (this->user_name_ != nullptr)
      return *(this->user_name_);
    else
      throw std::logic_error("Error: the \"user_name\" param is null");
  }

  ROLES get_user_role() {
    if (this->user_role_ != nullptr)
      return *(this->user_role_);
    else
      throw std::logic_error("Error: the \"user_role\" param is null");
  }

  void set_user_token(const std::shared_ptr<std::string> &user_token) {
    if (user_token != nullptr)
      this->user_token_ = user_token;
    else
      throw std::logic_error("Error: the \"user_token\" arg is null");
  }

  void set_user_name(const std::shared_ptr<std::string> &user_name) {
    if (user_name != nullptr)
      this->user_name_ = user_name;
    else
      throw std::logic_error("Error: the \"user_name\" arg is null");
  }

  void set_user_role(const std::shared_ptr<ROLES> &user_role) {
    if (user_role != nullptr)
      this->user_role_ = user_role;
    else
      throw std::logic_error("Error: the \"user_role\" arg is null");
  }

private:
  std::shared_ptr<std::string> user_token_;
  std::shared_ptr<std::string> user_name_;
  std::shared_ptr<ROLES> user_role_;
};

#endif
