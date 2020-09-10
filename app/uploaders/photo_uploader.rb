# frozen_string_literal: true

class PhotoUploader < BaseUploader
  include CarrierWave::MiniMagick

  process :add_text, if: :is_not_gif?

  # Override the filename of the uploaded files:
  def filename
    if super.present?
      @name ||= SecureRandom.uuid
      "#{Time.now.year}/#{@name}.#{file.extension.downcase}"
    end
  end

  def add_text
    manipulate! do |image|
      height = image.height
      width = image.width
      scale = height > width ? height : width
      size = scale * (0.003) * 20
      image.combine_options do |c|
        c.gravity "southeast"
        c.pointsize "#{size}"
        c.font "#{Rails.root}/app/assets/fonts/SweetlyBroken.ttf"
        c.draw "text 0, 0 'testerhome.com'"
        c.fill "#ccc"
      end
      image
    end
  end

  def is_not_gif?(img)
    !img.content_type.include? "gif"
  end
end
