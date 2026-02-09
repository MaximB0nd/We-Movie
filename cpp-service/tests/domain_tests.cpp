#include <gtest/gtest.h>
#include <memory>
#include <string>

#include "../source/domain/models/Media.hpp"
#include "../source/domain/models/Session.hpp"
#include "../source/domain/models/User.hpp"
#include "../source/domain/values/Roles.hpp"

TEST(UserModelInitTest, HandlesInit) {
  auto user_token = std::make_shared<std::string>("xFdGm12Fg");
  auto user_name = std::make_shared<std::string>("aleks");
  auto user_role = std::make_shared<ROLES>(ADMIN);

  auto user = std::make_shared<User>(user_token, user_name, user_role);

  EXPECT_NE(user, nullptr);
  EXPECT_EQ(user->get_user_token(), *user_token);
  EXPECT_EQ(user->get_user_name(), *user_name);
  EXPECT_EQ(user->get_user_role(), *user_role);
}

TEST(MediaModelInitTest, HandlesInit) {
  auto media_token = std::make_shared<std::string>("xjHgfnN6Jfh78");
  auto media_length_sec = std::make_shared<int>(10983);
  auto media_name = std::make_shared<std::string>("Гадкий Я");
  auto media_hls_link =
      std::make_shared<std::string>("https://1.1.1.1/media/5931392.m3u8");
  auto media_category = std::make_shared<std::string>("Мультфильм");

  auto media =
      std::make_shared<Media>(media_token, media_length_sec, media_name,
                              media_hls_link, media_category);

  EXPECT_NE(media, nullptr);
  EXPECT_EQ(media->get_media_token(), *media_token);
  EXPECT_EQ(media->get_media_length_sec(), *media_length_sec);
  EXPECT_EQ(media->get_media_name(), *media_name);
  EXPECT_EQ(media->get_media_hls_link(), *media_hls_link);
}

TEST(SessionModelInitTest, HandlesInit) {
  auto session_token = std::make_shared<std::string>("xdsf32DKsjfdk");

  auto user_token = std::make_shared<std::string>("xFdGm12Fg");
  auto user_name = std::make_shared<std::string>("aleks");
  auto user_role = std::make_shared<ROLES>(ADMIN);

  auto user = std::make_shared<User>(user_token, user_name, user_role);
  auto session_users = std::make_shared<std::set<std::shared_ptr<User>>>();
  session_users->insert(user);

  auto media_token = std::make_shared<std::string>("xjHgfnN6Jfh78");
  auto media_length_sec = std::make_shared<int>(10983);
  auto media_name = std::make_shared<std::string>("Гадкий Я");
  auto media_hls_link =
      std::make_shared<std::string>("https://1.1.1.1/media/5931392.m3u8");
  auto media_category = std::make_shared<std::string>("Мультфильм");

  auto session_media =
      std::make_shared<Media>(media_token, media_length_sec, media_name,
                              media_hls_link, media_category);

  auto session =
      std::make_shared<Session>(session_token, session_users, session_media);

  EXPECT_NE(session, nullptr);
  EXPECT_EQ(session->get_session_token(), *session_token);
  EXPECT_EQ(session->get_session_users(), *session_users);
  EXPECT_EQ(session->get_session_media().get_media_name(),
            session_media->get_media_name());
}
