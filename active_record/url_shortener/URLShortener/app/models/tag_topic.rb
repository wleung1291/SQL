# == Schema Information
#
# Table name: tag_topics
#
#  id         :bigint           not null, primary key
#  topic      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class TagTopic < ApplicationRecord
  validates :topic, presence: true

  # Gets every tagging info for the topic 
  has_many :tags,
    primary_key: :id,
    foreign_key: :tag_topic_id,
    class_name: :Tagging

  # gets every url info for the topic 
  has_many :shortened_urls,
    through: :tags,
    source: :shortened_url

end
