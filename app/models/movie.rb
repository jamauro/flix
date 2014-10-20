class Movie < ActiveRecord::Base
  has_many :reviews, dependent: :destroy # dependent destroy deletes reviews associated with movie if the movie gets deleted
  has_attached_file :image

  RATINGS = %w(G PG PG-13 R NC-17)

  validates :title, :released_on, :duration, presence: true
  validates :description, length: { minimum: 25 }
  validates :total_gross, numericality: { greater_than_or_equal_to: 0 }
  validates_attachment :image,
    :content_type => { :content_type => ['image/jpeg', 'image/png'] },
    :size => { :less_than => 1.megabyte }
  validates :rating, inclusion: { in: RATINGS }

  def self.released
    where("released_on <= ?", Time.now).order("released_on desc")
  end

  def self.hits
    where('total_gross >= 300000000').order('total_gross desc')
  end

  def self.flops
    where('total_gross < 10000000').order('total_gross asc')
  end

  def self.recently_added
    order('created_at desc').limit(3)
  end

  def flop?
    if reviews.size > 5 && average_stars > 4
      false
    else
      total_gross.blank? || total_gross < 50000000
    end
  end

  def average_stars
    reviews.average(:stars)
  end

  def recent_reviews
    reviews.order('created_at desc').limit(2)
  end
end
