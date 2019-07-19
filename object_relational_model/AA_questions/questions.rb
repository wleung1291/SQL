require 'sqlite3'
require 'singleton'
require_relative 'user'
require_relative 'reply'
require_relative 'question_follow'
require_relative 'question_like'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end


class Question
  attr_accessor :id, :title, :body, :users_id

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM questions")
    data.map { |datum| Question.new(datum) }
  end

  def initialize (options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @users_id = options['users_id']
  end

  def save
    if @id 
      QuestionsDatabase.instance.execute(<<-SQL, title, body, users_id, id)
        UPDATE
          questions
        SET 
          title = ?, body = ?, users_id = ?
        WHERE 
          questions.id = ?
      SQL
    else
      QuestionsDatabase.instance.execute(<<-SQL, title, body, users_id)
        INSERT INTO
          questions (title, body, users_id)
        VALUES
          (?, ?, ?)
      SQL

      @id = QuestionsDatabase.instance.last_insert_row_id
    end
  end

  def remove
    if @id 
      QuestionsDatabase.instance.execute(<<-SQL, id)
        DELETE FROM
          questions
        WHERE 
          questions.id = ?
      SQL
    end
  end
  
  def self.find_by_id(id)
    question_data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT 
        *
      FROM
        questions
      WHERE
        id = ?
    SQL

    return nil if question_data.nil?
    question_data.map {|q| Question.new(q) }
  end
  
  def self.find_by_author_id(users_id)
    question_data = QuestionsDatabase.instance.execute(<<-SQL, users_id)
      SELECT
        *
      FROM 
        questions
      WHERE
        users_id = ?
    SQL
    
    return nil if question_data.nil? 
    question_data.map {|question| Question.new(question)  }
  end

  # Author of the question
  def author
    User.find_by_id(users_id)
  end

  # Replies to the question
  def replies 
    Reply.find_by_question_id(id)
  end

  def followers
    QuestionFollow.followers_for_question_id(id)
  end

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end

  def likers
    QuestionLike.likers_for_question_id(id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(id)
  end

  # Fetches n most liked questions.
  def self.most_liked(n)
    QuestionLike.most_liked_questions(n)
  end

end
