class Year < ActiveRecord::Base
  has_many :bookmarks, :order => :bookmarked_at

  def volume_number
    year_string.to_i - 2012 + 1
  end
  
end

class Bookmark < ActiveRecord::Base
  belongs_to :year

  def tags
<<<<<<< HEAD
    if raw_tags
      raw_tags.split(" ")
=======
    # Fixed by @infovore
    if raw_tags
      raw_tags.split(' ')
>>>>>>> Markpond-specific changes
    else
      []
    end
  end
  
  def year
    bookmarked_at.strftime('%Y')
  end

  def month
    bookmarked_at.strftime('%B')
  end

  def day
    bookmarked_at.strftime("%d")
  end

  def qr_for_url
    if archive
      "http://qrcode.kaywa.com/img.php?s=8&d=#{CGI.escape(archive)}"
    else
      "http://qrcode.kaywa.com/img.php?s=8&d=#{CGI.escape(href)}"
    end
  end
end
