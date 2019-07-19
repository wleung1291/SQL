# == Schema Information
#
# Table name: taggings
#
#  id           :bigint           not null, primary key
#  tag_topic_id :integer          not null
#  url_id       :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Tagging < ApplicationRecord
  validates :tag_topic_id, :url_id, presence: true

  # gets the topic info for the tagging
  belongs_to :tag_topic_name,
    primary_key: :id,  
    foreign_key: :tag_topic_id,
    class_name: :TagTopic

  # gets the url info for the tagging
  belongs_to :shortened_url,
    primary_key: :id,
    foreign_key: :url_id,
    class_name: :ShortenedUrl
end
