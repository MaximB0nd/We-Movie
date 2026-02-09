#ifndef H_SESSION_CLASS
#define H_SESSION_CLASS 

#include <set>
#include <stdexcept>
#include <string> 
#include <memory> 

#include "User.hpp"
#include "Media.hpp" 
#include "Roles.hpp" 

class Session {
    
    public:
        Session(std::shared_ptr<std::string> session_token,
                std::shared_ptr<std::set<User>> session_users,
                std::shared_ptr<Media> session_media) : session_token_(std::move(session_token)),
                                                        session_users_(std::move(session_users)),
                                                        session_media_(std::move(session_media)) {

                                                        } 
        ~Session(){}

        std::string get_session_token() {
            if (this->session_token_) return *(this->session_token_);
            else throw std::logic_error("Error: the \"session_token\" param is null");
        }

        std::set<User> get_session_users() {
            if (this->session_users_) return *(this->session_users_);
            else throw std::logic_error("Error: the \"session_users\" param is null");
        }

        Media get_session_media() {
            if (this->session_media_) return *(this->session_media_);
            else throw std::logic_error("Error: the \"session_media\" param is null");
        }

        void set_session_token(const std::shared_ptr<std::string>& session_token) {
            if (session_token) this->session_token_ = session_token;
            else throw std::logic_error("Error: the \"session_token\" arg is null");
        }

        void set_session_users(const std::shared_ptr<std::set<User>>& session_users) {
            if (session_users) this->session_users_ = session_users;
            else throw std::logic_error("Error: the \"session_uesrs\" arg is null");
        }

        void set_sesssion_media(const std::shared_ptr<Media>& session_media) {
            if (session_media) this->session_media_ = session_media;
            else throw std::logic_error("Error: the \"session_media\" arg is null");
        }
        
    private:
        // std::shared_ptr<Chat> chat_;
        std::shared_ptr<std::string> session_token_;
        std::shared_ptr<std::set<User>> session_users_;
        std::shared_ptr<Media> session_media_;
};

#endif 
