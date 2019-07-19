require_relative 'questions'
require_relative 'user'
require_relative 'question_like'

class QuestionFollow
  attr_accessor :id, :users_id, :questions_id

  def initialize(options)
    @id = options['id']
    @users_id = options['users_id']
    @questions_id = options['questions_id']
  end

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM question_follows")
    data.map { |datum| QuestionFollow.new(datum) }
  end

  def self.find_by_id(id)
    q_follower_data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT 
        *
      FROM
        question_follows
      WHERE
        id = ?
    SQL

    return nil if q_follower_data.nil?
    q_follower_data.map {|data| QuestionFollow.new(data) }
  end

  # This will return an array of User objects!
  def self.followers_for_question_id(question_id)
    followers = QuestionsDatabase.instance.execute(<<-SQL, question_id) 
      SELECT 
        *
      FROM
        users
      JOIN 
        question_follows ON users.id = question_follows.users_id
      WHERE 
        question_follows.questions_id = ?
    SQL

    followers.map { |data| User.new(data) }
  end
  
  # Returns an array of Question objects.
  def self.followed_questions_for_user_id(user_id)
    followed_q = QuestionsDatabase.instance.execute(<<-SQL, user_id) 
      SELECT 
        *
      FROM
        questions
      JOIN 
        question_follows ON questions.id = question_follows.questions_id
      WHERE 
        question_follows.users_id = ?
    SQL
   
    followed_q.map { |data| Question.new(data) }
  end
  
  # Fetches the n most followed questions.
  def self.most_followed_questions(n)
    most_followed_q = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        *
      FROM 
        questions
      JOIN
        question_follows ON question_follows.questions_id = questions.id
      GROUP BY
        questions.id
      ORDER BY 
        COUNT(*) DESC
      LIMIT 
        ?
    SQL

    most_followed_q.map {|data| Question.new(data)}
  end

end