# frozen_string_literal: true

module Homeland
  class Pipeline
    class EmbedVideoFilter < HTML::Pipeline::TextFilter
      YOUTUBE_URL_REGEXP = %r{(\s|^|<div>|<br>)(https?://)(www.)?(youtube\.com/watch\?v=|youtu\.be/|youtube\.com/watch\?feature=player_embedded&v=)([A-Za-z0-9_\-]*)(\&\S+)?(\?\S+)?}
      YOUKU_URL_REGEXP   = %r{(\s|^|<div>|<br>)(http?://)(v\.youku\.com/v_show/id_)([a-zA-Z0-9\-_\=]*)(\.html)(\&\S+)?(\?\S+)?}
      VIMEO_URL_REGEXP   = %r{(\s|^|<div>|<br>)(https?://)(vimeo\.com/)([0-9]+)(\&\S+)?(\?\S+)?}
      MYSLIDE_URL_REGEXP = %r{(\s|^|<div>|<br>)(https?://)(myslide\.cn/slides/)([0-9]+)(\&\S+)?(\?\S+)?}
      SHENGXIANG_URL_REGEXP = %r{(\s|^|<div>|<br>)(https://)(ppt\.baomitu\.com/d/)([A-Za-z0-9_\-]*)(\&\S+)?(\?\S+)?}
      JINSHUJU_URL_REGEXP = %r{(\s|^|<div>|<br>)(https://)([A-Za-z0-9_\-]*\.?jinshuju\.(net|com)/f/)([A-Za-z0-9_\-]*)\?(height=)([0-9]+)(\&\S+)?(\?\S+)?}

      def call
        wmode = context[:video_wmode]
        autoplay = context[:video_autoplay] || false
        hide_related = context[:video_hide_related] || false

        @text.gsub!(YOUTUBE_URL_REGEXP) do
          youtube_id = Regexp.last_match(5)
          close_tag = Regexp.last_match(1) if ["<br>", "<div>"].include? Regexp.last_match(1)
          src = "//www.youtube.com/embed/#{youtube_id}"
          params = []
          params << "wmode=#{wmode}" if wmode
          params << "autoplay=1" if autoplay
          params << "rel=0" if hide_related
          src += "?#{params.join '&'}" unless params.empty?
          embed_tag(close_tag, src)
        end

        @text.gsub!(VIMEO_URL_REGEXP) do
          vimeo_id = Regexp.last_match(4)
          close_tag = Regexp.last_match(1) if ["<br>", "<div>"].include? Regexp.last_match(1)
          src = "https://player.vimeo.com/video/#{vimeo_id}"
          embed_tag(close_tag, src)
        end

        @text.gsub!(YOUKU_URL_REGEXP) do
          youku_id = Regexp.last_match(4)
          src = "//player.youku.com/embed/#{youku_id}"
          close_tag = Regexp.last_match(1) if ["<br>", "<div>"].include? Regexp.last_match(1)
          embed_tag(close_tag, src)
        end

        @text.gsub!(MYSLIDE_URL_REGEXP) do
          slide_id = Regexp.last_match(4)
          close_tag = Regexp.last_match(1) if ["<br>", "<div>"].include? Regexp.last_match(1)
          src = "https://myslide.cn/html_player/#{slide_id}"
          slide_embed_tag(close_tag, src)
        end

        @text.gsub!(JINSHUJU_URL_REGEXP) do
          shuju_id = Regexp.last_match(5)
          height = Regexp.last_match(7)
          url = Regexp.last_match(3)
          src = "https://#{url}#{shuju_id}?background=white&banner=show&embedded=true"
          jinshuju_embed_tag(src, height, shuju_id)
        end

        @text.gsub!(SHENGXIANG_URL_REGEXP) do
          slide_id = Regexp.last_match(4)
          close_tag = Regexp.last_match(1) if ["<br>", "<div>"].include? Regexp.last_match(1)
          src = "https://ppt.baomitu.com/embed/#{slide_id}?style=dark"
          shengxiang_embed_tag(close_tag, src)
        end

        @text
      end

      def embed_tag(close_tag, src)
        %(#{close_tag}<span class="embed-responsive embed-responsive-16by9"><iframe class="embed-responsive-item" src="#{src}" allowfullscreen></iframe></span>)
      end

      def slide_embed_tag(close_tag, src)
        %(#{close_tag}<span class="embed-responsive slide-iframe"><iframe class="embed-responsive-item" src="#{src}" allowfullscreen></iframe></span>)
      end

      def jinshuju_embed_tag(src, height, shuju_id)
        %(<iframe id="goldendata_form_#{shuju_id}" src="#{src}" width="100%" frameborder=0 allowTransparency="true" height="#{height}"></iframe>)
      end

      def shengxiang_embed_tag(close_tag, src)
        %(#{close_tag}<iframe src="#{src}" width="100%" height="100%" scrolling="no" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen allowfullscreen></iframe>)
      end

    end
  end
end
