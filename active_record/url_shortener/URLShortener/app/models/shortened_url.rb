# == Schema Information
#
# Table name: shortened_urls
#
#  id           :bigint           not null, primary key
#  long_url     :string           not null
#  short_url    :string           not null
#  submitter_id :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class ShortenedUrl < ApplicationRecord
  validates :long_url, :short_url, :submitter_id, presence: true

  belongs_to :submitter,
    primary_key: :id,
    foreign_key: :submitter_id,
    class_name: :User
    
  # visits to a url
  has_many :clicks,
    primary_key: :id,
    foreign_key: :shortened_url_id,
    class_name: :Visit  
    
  # users who clicked the url
  has_many :visitors,
    Proc.new {distinct},
    through: :clicks,
    source: :visitor

  # gets the tagging info from taggings table for the url
  has_many :tags,
    primary_key: :id,
    foreign_key: :url_id,
    class_name: :Tagging

  # gets the topic name of the url
  has_many :tag_topics,
    through: :tags,
    source: :tag_topic_name

  
  def self.prune(n)
    ShortenedUrl
      .joins(:submitter) #'JOIN users ON users.id = shortened_urls.submitter_id'
      .joins('LEFT JOIN visits ON visits.shortened_url_id = shortened_urls.id')
      .where("(shortened_urls.id IN (
        SELECT shortened_urls.id
        FROM shortened_urls
        JOIN visits
        ON visits.shortened_url_id = shortened_urls.id
        GROUP BY shortened_urls.id
        HAVING MAX(visits.created_at) < \'#{n.minute.ago}\'
      ) OR (
        visits.id IS NULL and shortened_urls.created_at < \'#{n.minutes.ago}\'
      )) AND users.premium = \'f\'")
      .destroy_all
  end

  def no_spamming
    # returns a hash of {submitter_id => count of submitted urls}
    url_count = ShortenedUrl.where("created_at >= ?", 5.minutes.ago)
      .group(:submitter_id).count
 
    if url_count[submitter_id] > 5
      errors.add(:submitter_id, 'Too many submitted urls') unless 
        User.find_by(id: submitter_id).premium 
    end

  end

  # creates the short url 
  def self.random_code
    loop do
      random_16_byte_code = SecureRandom::urlsafe_base64(16)
      return random_16_byte_code unless ShortenedUrl.exists?(random_16_byte_code)
    end
  end

  # takes a User object and a long_url string and creates a new ShortenedUrl
  def self.new_short_url(user, long_url)
    ShortenedUrl.create!(submitter_id: user.id, long_url: long_url, 
      short_url: ShortenedUrl.random_code)
  end

  # count the number of clicks on a ShortenedUrl
  def num_clicks
    clicks.count
  end

  # determine the number of distinct users who have clicked a link
  def num_uniques
    visitors.count
  end

  # should only collect unique clicks in a recent time period
  def num_recent_uniques
    clicks.select(:user_id).where('created_at > ?', 10.minutes.ago).distinct.count
  end

end
