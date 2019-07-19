# == Schema Information
#
# Table name: questions
#
#  id         :bigint           not null, primary key
#  text       :string           not null
#  poll_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Question < ApplicationRecord
  validates :text, presence: true

  has_many :answer_choices,
    primary_key: :id,
    foreign_key: :question_id,
    class_name: 'AnswerChoice'

  belongs_to :poll,
    class_name: 'Poll',
    primary_key: :id,
    foreign_key: :poll_id

  has_many :responses,
    through: :answer_choices, # question model association above
    source: :responses  # association in answer_choice model
  
  # returns a hash of choices and counts 
  def results_n_plus_1
    results = {}
    self.answer_choices.each do |ac|
      # calls responses association from answer_choice model
      results[ac.text] = ac.responses.count
    end

    return results
  end
  # use includes to pre-fetch all the responses at the same time you fetch the 
  # answer_choices
  def results_includes
    results = {}
    self.answer_choices.includes(:responses).each do |ac|
      # calls responses association from answer_choice model
      results[ac.text] = ac.responses.length
    end

    return results
  end


  def results_sql
    ac_objects = AnswerChoice.find_by_sql([<<-SQL, id])
      SELECT
        answer_choices.text, COUNT(responses.id)
      FROM
        answer_choices
      LEFT OUTER JOIN 
        responses ON answer_choices.id = responses.answer_choice_id
      WHERE
        answer_choices.question_id = ?
      GROUP BY
        answer_choices.id
    SQL

    results = {}
    ac_objects.each do |ac|
      results[ac.text] = ac.count
    end
    
    return results
  end

  # most efficient way
  def results_active_record
    ac_objects = self.answer_choices # uses Question#answer_choices association 
      .select("answer_choices.text, COUNT(responses.id)")
      .left_outer_joins(:responses) # uses AnswerChoice#responses association
      .where(answer_choices: {question_id: self.id})
      .group("answer_choices.id")

    results = {}
    ac_objects.each do |ac|
      results[ac.text] = ac.count
    end

    return results
  end
  
end
