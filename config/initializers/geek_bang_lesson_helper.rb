class GeekBangLessonHelper
  class << self
    def fetch_token(force = false)
      if force
        Rails.cache.delete("geekbang_lesson_token")
      end
      dict = {
        app_id: Setting.geekbang_app_id,
        app_secret: Setting.geekbang_app_secret,
      }

      Rails.cache.fetch("geekbang_lesson_token_#{dict.hash}", expires_in: 1.hour) do
        url = "https://open.geekbang.org/serv/v1/es/auth"
        answer = DefaultRest.post(url, dict)

        if answer[:code] == 0
          answer[:data][:token]
        else
          raise "获取 GeekBang token 失败"
        end
      end
    end

    def force_update_cache
      list = fetch_list
      list.each do |item|
        Rails.cache.delete("geekbang_lesson_#{item[:course_id]}")
      end
      fetch_token(true)
      fetch_list(true)
    end

    def fetch_list(force = false, details = true)
      url = "https://open.geekbang.org/serv/v1/course/list"

      Rails.cache.delete("geekbang_lesson_list") if force
      answer = Rails.cache.read("geekbang_lesson_list")
      return answer if answer.present?

      token = fetch_token
      courses = DefaultRest.post(url, token: token, type: 7, size: 99)
      if courses[:code] == 0
        list = courses[:data][:list]

        if details
          list.each do |item|
            item[:details] = fetch_lesson_details(item[:course_id])
          end
        end

        Rails.cache.write("geekbang_lesson_list", list, expires_in: 1.hours)
      end

      list
    end

    def fetch_lesson_details(id, force = false)
      url = "https://open.geekbang.org/serv/v1/course/info"
      Rails.cache.delete("geekbang_lesson_#{id}") if force

      answer = Rails.cache.read("geekbang_lesson_#{id}")
      return answer if answer.present? && answer != {}

      token = fetch_token
      details = DefaultRest.post(url, token: token, course_id: id.to_i)
      if details[:code] == 0
        Rails.cache.write("geekbang_lesson_#{id}", details[:data], expires_in: 1.hours)
      end

      details[:data]
    end

    def fetch_article_id_from_course_id(course_id)
      cource_info = fetch_lesson_details(course_id)
      id = cource_info.dig(:chapters, 0, :articles, 0, :article_id)
      return id unless id.blank?

      cource_info.dig(:articles, 0, :article_id)
    end

    def fetch_article_info(id, force = false)
      Rails.cache.delete("geekbang_lesson_article_#{id}") if force

      answer = Rails.cache.read("geekbang_lesson_article_#{id}")
      return answer if answer.present? && answer != {}

      url = "https://open.geekbang.org/serv/v1/article/info"

      answer = DefaultRest.post(url, token: fetch_token, article_id: id.to_i)
      if answer[:code] == 0
        Rails.cache.write("geekbang_lesson_article_#{id}", answer[:data], expires_in: 1.hours)
        answer[:data]
      else
        nil
      end
    end
  end
end
