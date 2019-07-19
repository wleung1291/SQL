require_relative 'questions'
require_relative 'user'
require_relative 'question_follow'

class QuestionLike
  attr_accessor :id, :users_id, :questions_id

  def initialize(options)
    @id = options['id']
    @users_id = options['users_id']
    @questions_id = options['questions_id']
  end

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM question_likes")
    data.map { |datum| QuestionLike.new(datum) }
  end

  def self.find_by_id(id)
    q_likes_data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT 
        *
      FROM
        question_likes
      WHERE
        id = ?
    SQL

    return nil if q_likes_data.nil?
    q_likes_data.map {|data| QuestionLikes.new(data) }
  end

  def self.likers_for_question_id(question_id)
    likers_for_q = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        users
      JOIN
        question_likes ON question_likes.users_id = users.id
      WHERE
        question_likes.questions_id = ?
    SQL

    likers_for_q.map {|data| User.new(data) }
  end

  def self.num_likes_for_question_id(question_id)
    num_likes_for_q = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        COUNT(*)
      FROM
        questions
      JOIN
        question_likes ON question_likes.questions_id = questions.id
      WHERE
        question_likes.questions_id = ?
    SQL
  end

  def self.liked_questions_for_user_id(user_id)
     liked_q_for_user = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        questions
      JOIN
        question_likes ON question_likes.questions_id = questions.id
      WHERE
        question_likes.users_id = ?
    SQL

    liked_q_for_user.map {|data| Question.new(data) }
  end

  def self.most_liked_questions(n)
    most_liked_q = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        *
      FROM
        questions
      JOIN
        question_likes ON question_likes.questions_id = questions.id
      GROUP BY
        questions.id
      ORDER BY
        COUNT(*) DESC
      LIMIT
        ?
    SQL

    most_liked_q.map {|data| Question.new(data) }
  end

end