# frozen_string_literal: true

# =============================================================================
# LMS API シードデータ
#
# 冪等（何回実行しても安全）: find_or_create_by を使用し、
# 既存レコードがあればスキップします。
# テスト環境ではスキップ（テストは factory_bot で独自にデータを作成する）
# =============================================================================

return if Rails.env.test?

puts "=== Seeding LMS API ==="

# -----------------------------------------------------------------------------
# 1. Users
# -----------------------------------------------------------------------------
puts "  Creating users..."

admin = User.find_or_create_by!(email: "admin@example.com") do |u|
  u.name = "Admin User"
  u.password = "password123"
  u.password_confirmation = "password123"
  u.role = :admin
  u.email_verified_at = Time.current
end

instructor1 = User.find_or_create_by!(email: "yazawa.naoki.01@gmail.com") do |u|
  u.name = "田中 太郎"
  u.password = "password123"
  u.password_confirmation = "password123"
  u.role = :instructor
  u.email_verified_at = Time.current
end

instructor2 = User.find_or_create_by!(email: "yazawa.naoki@ficilcom.jp") do |u|
  u.name = "鈴木 花子"
  u.password = "password123"
  u.password_confirmation = "password123"
  u.role = :instructor
  u.email_verified_at = Time.current
end

student1 = User.find_or_create_by!(email: "naoki.a.yazawa@gmail.com") do |u|
  u.name = "山田 一郎"
  u.password = "password123"
  u.password_confirmation = "password123"
  u.role = :student
  u.email_verified_at = Time.current
end

student2 = User.find_or_create_by!(email: "sato@example.com") do |u|
  u.name = "佐藤 美咲"
  u.password = "password123"
  u.password_confirmation = "password123"
  u.role = :student
  u.email_verified_at = Time.current
end

student3 = User.find_or_create_by!(email: "watanabe@example.com") do |u|
  u.name = "渡辺 健太"
  u.password = "password123"
  u.password_confirmation = "password123"
  u.role = :student
  u.email_verified_at = Time.current
end

puts "    Users: #{User.count}"

# -----------------------------------------------------------------------------
# 2. Courses + Sections + Lessons
# -----------------------------------------------------------------------------
puts "  Creating courses..."

# --- Course 1: Published (beginner) ---
course1 = Course.find_or_create_by!(title: "Ruby入門", instructor: instructor1) do |c|
  c.description = "Rubyの基礎文法から実践的なプログラミングまでを学ぶ入門コースです。変数、制御構文、メソッド、クラスなど、Rubyの基本を網羅します。"
  c.category = "プログラミング"
  c.difficulty = :beginner
  c.max_enrollment = 30
end

if course1.sections.empty?
  s1 = course1.sections.create!(title: "Rubyの基礎", position: 0)
  s1.lessons.create!(title: "Rubyとは？", content_type: :text, content_body: "Rubyは日本発のプログラミング言語で、まつもとゆきひろ氏によって開発されました。", duration_minutes: 10, position: 0)
  s1.lessons.create!(title: "変数とデータ型", content_type: :text, content_body: "Rubyの変数はローカル変数、インスタンス変数、クラス変数、グローバル変数の4種類があります。", duration_minutes: 15, position: 1)
  s1.lessons.create!(title: "制御構文", content_type: :text, content_body: "if/unless、while/until、case/when などの制御構文を学びます。", duration_minutes: 20, position: 2)

  s2 = course1.sections.create!(title: "オブジェクト指向プログラミング", position: 1)
  s2.lessons.create!(title: "クラスとインスタンス", content_type: :text, content_body: "Rubyはすべてがオブジェクトです。クラスの定義方法とインスタンスの生成を学びます。", duration_minutes: 25, position: 0)
  s2.lessons.create!(title: "継承とモジュール", content_type: :text, content_body: "単一継承とモジュールによるミックスインを理解します。", duration_minutes: 20, position: 1)
  s2.lessons.create!(title: "まとめクイズ", content_type: :quiz, content_body: '{"questions":[{"q":"Rubyの作者は？","a":"まつもとゆきひろ"},{"q":"Rubyの変数は何種類？","a":"4種類"}]}', duration_minutes: 10, position: 2)
end

# --- Course 2: Published (intermediate) ---
course2 = Course.find_or_create_by!(title: "Rails実践開発", instructor: instructor1) do |c|
  c.description = "Ruby on Railsを使ったWebアプリケーション開発の実践コースです。MVC、RESTful API、テスト駆動開発を学びます。"
  c.category = "Web開発"
  c.difficulty = :intermediate
  c.max_enrollment = 25
end

if course2.sections.empty?
  s1 = course2.sections.create!(title: "Rails基礎", position: 0)
  s1.lessons.create!(title: "Railsプロジェクトの構成", content_type: :text, content_body: "Railsのディレクトリ構成とMVCパターンについて解説します。", duration_minutes: 20, position: 0)
  s1.lessons.create!(title: "ルーティングとコントローラー", content_type: :video, content_body: "https://example.com/videos/rails-routing", duration_minutes: 30, position: 1)
  s1.lessons.create!(title: "Active Record入門", content_type: :text, content_body: "ORMとしてのActive Recordの基本的な使い方を学びます。", duration_minutes: 25, position: 2)

  s2 = course2.sections.create!(title: "API開発", position: 1)
  s2.lessons.create!(title: "RESTful APIの設計", content_type: :text, content_body: "RESTの原則に基づいたAPI設計のベストプラクティスを学びます。", duration_minutes: 25, position: 0)
  s2.lessons.create!(title: "認証とセキュリティ", content_type: :video, content_body: "https://example.com/videos/rails-auth", duration_minutes: 35, position: 1)

  s3 = course2.sections.create!(title: "テスト", position: 2)
  s3.lessons.create!(title: "RSpecによるテスト", content_type: :text, content_body: "RSpecを使ったモデル・コントローラーのテスト手法を学びます。", duration_minutes: 30, position: 0)
  s3.lessons.create!(title: "テスト実践クイズ", content_type: :quiz, content_body: '{"questions":[{"q":"RSpecのdescribeは何を定義する？","a":"テストグループ"}]}', duration_minutes: 15, position: 1)
end

# --- Course 3: Published (advanced) ---
course3 = Course.find_or_create_by!(title: "Railsアーキテクチャパターン", instructor: instructor2) do |c|
  c.description = "Rails アプリケーションの設計パターンを学ぶ上級コースです。レイヤードアーキテクチャ、サービスオブジェクト、ポリシーオブジェクトなどを扱います。"
  c.category = "ソフトウェア設計"
  c.difficulty = :advanced
end

if course3.sections.empty?
  s1 = course3.sections.create!(title: "レイヤードアーキテクチャ", position: 0)
  s1.lessons.create!(title: "なぜレイヤー分割が必要か", content_type: :text, content_body: "Railsの「太ったモデル」問題と、レイヤードアーキテクチャによる解決策を学びます。", duration_minutes: 20, position: 0)
  s1.lessons.create!(title: "サービスオブジェクト", content_type: :text, content_body: "ビジネスロジックをサービスオブジェクトに切り出すパターンを学びます。", duration_minutes: 25, position: 1)

  s2 = course3.sections.create!(title: "認可とポリシー", position: 1)
  s2.lessons.create!(title: "ポリシーオブジェクト", content_type: :text, content_body: "Action Policyを使った認可ロジックの分離を学びます。", duration_minutes: 25, position: 0)
  s2.lessons.create!(title: "アーキテクチャクイズ", content_type: :quiz, content_body: '{"questions":[{"q":"サービスオブジェクトの主な責務は？","a":"ビジネスロジックのカプセル化"}]}', duration_minutes: 10, position: 1)
end

# --- Course 4: Draft ---
course4 = Course.find_or_create_by!(title: "データベース設計入門", instructor: instructor2) do |c|
  c.description = "リレーショナルデータベースの設計原則を学ぶコースです。正規化、インデックス、パフォーマンスチューニングを扱います。"
  c.category = "データベース"
  c.difficulty = :beginner
end

# Draft コースにもコンテンツを追加（レビュー提出前の準備中）
if course4.sections.empty?
  s1 = course4.sections.create!(title: "RDBの基礎", position: 0)
  s1.lessons.create!(title: "テーブル設計の基本", content_type: :text, content_body: "リレーショナルデータベースにおけるテーブル設計の基本原則を学びます。", duration_minutes: 20, position: 0)
end

puts "    Courses: #{Course.count}"

# -----------------------------------------------------------------------------
# 3. Publish courses via AASM state transitions
# -----------------------------------------------------------------------------
puts "  Publishing courses..."

[course1, course2, course3].each do |course|
  course.reload
  if course.draft?
    course.submit_for_review!
    course.approve!
    puts "    Published: #{course.title}"
  elsif course.under_review?
    course.approve!
    puts "    Published: #{course.title}"
  else
    puts "    Already published: #{course.title}"
  end
end

# -----------------------------------------------------------------------------
# 4. Enrollments
# -----------------------------------------------------------------------------
puts "  Creating enrollments..."

# student1: course1 を完了済み、course2 を受講中
enrollment1 = Enrollment.find_or_create_by!(user: student1, course: course1) do |e|
  e.enrolled_at = 2.months.ago
end

enrollment2 = Enrollment.find_or_create_by!(user: student1, course: course2) do |e|
  e.enrolled_at = 1.month.ago
end

# student2: course1 を受講中、course3 を受講中
enrollment3 = Enrollment.find_or_create_by!(user: student2, course: course1) do |e|
  e.enrolled_at = 3.weeks.ago
end

enrollment4 = Enrollment.find_or_create_by!(user: student2, course: course3) do |e|
  e.enrolled_at = 1.week.ago
end

# student3: course2 をペンディング
enrollment5 = Enrollment.find_or_create_by!(user: student3, course: course2) do |e|
  e.enrolled_at = 2.days.ago
end

# Activate enrollments (pending → active)
[enrollment1, enrollment2, enrollment3, enrollment4, enrollment5].each do |e|
  e.reload
  if e.pending?
    e.activate!
  end
end

puts "    Enrollments: #{Enrollment.count}"

# -----------------------------------------------------------------------------
# 5. Lesson Progresses
# -----------------------------------------------------------------------------
puts "  Creating lesson progresses..."

# student1 × course1: 全レッスン完了
course1.lessons.each do |lesson|
  lp = LessonProgress.find_or_create_by!(enrollment: enrollment1, lesson: lesson) do |p|
    p.status = :completed
    p.completed_at = 1.month.ago
  end
  unless lp.completed?
    lp.update!(status: :completed, completed_at: 1.month.ago)
  end
end

# student1 × course2: 一部レッスン完了（進行中）
course2.lessons.each_with_index do |lesson, i|
  lp = LessonProgress.find_or_create_by!(enrollment: enrollment2, lesson: lesson) do |p|
    if i < 4
      p.status = :completed
      p.completed_at = 2.weeks.ago
    elsif i == 4
      p.status = :in_progress
    else
      p.status = :not_started
    end
  end
end

# student2 × course1: 途中まで完了
course1.lessons.each_with_index do |lesson, i|
  LessonProgress.find_or_create_by!(enrollment: enrollment3, lesson: lesson) do |p|
    if i < 3
      p.status = :completed
      p.completed_at = 1.week.ago
    else
      p.status = :not_started
    end
  end
end

# student2 × course3: 開始したばかり
course3.lessons.each_with_index do |lesson, i|
  LessonProgress.find_or_create_by!(enrollment: enrollment4, lesson: lesson) do |p|
    if i == 0
      p.status = :in_progress
    else
      p.status = :not_started
    end
  end
end

puts "    LessonProgresses: #{LessonProgress.count}"

# -----------------------------------------------------------------------------
# 6. Complete enrollment & Certificate (student1 × course1)
# -----------------------------------------------------------------------------
puts "  Completing enrollments and issuing certificates..."

enrollment1.reload
if enrollment1.active?
  enrollment1.complete!
  enrollment1.update!(completed_at: 1.month.ago)
  puts "    Completed: #{student1.name} × #{course1.title}"
end

cert = Certificate.find_or_create_by!(enrollment: enrollment1) do |c|
  c.certificate_number = "CERT-#{enrollment1.id}-#{SecureRandom.hex(4).upcase}"
end

if cert.pending?
  cert.issue!
  cert.update!(issued_at: 1.month.ago)
  puts "    Certificate issued: #{cert.certificate_number}"
end

# -----------------------------------------------------------------------------
# 7. Reviews
# -----------------------------------------------------------------------------
puts "  Creating reviews..."

Review.find_or_create_by!(user: student1, course: course1) do |r|
  r.rating = 5
  r.comment = "Ruby の基礎が体系的に学べる素晴らしいコースでした。初心者にとって最適な内容です。"
end

Review.find_or_create_by!(user: student2, course: course1) do |r|
  r.rating = 4
  r.comment = "わかりやすい説明で楽しく学べています。クイズがもう少し多いと嬉しいです。"
end

Review.find_or_create_by!(user: student1, course: course2) do |r|
  r.rating = 4
  r.comment = "実践的な内容で、すぐに仕事に活かせそうです。"
end

puts "    Reviews: #{Review.count}"

# -----------------------------------------------------------------------------
# 8. Notification Preferences
# -----------------------------------------------------------------------------
puts "  Creating notification preferences..."

User.find_each do |user|
  NotificationPreference.find_or_create_by!(user: user)
end

puts "    NotificationPreferences: #{NotificationPreference.count}"

# -----------------------------------------------------------------------------
# 9. Notifications
# -----------------------------------------------------------------------------
puts "  Creating notifications..."

Notification.find_or_create_by!(
  user: instructor1,
  notification_type: "new_enrollment",
  params: { student_name: student1.name, course_title: course1.title }
) do |n|
  n.read_at = 1.month.ago
end

Notification.find_or_create_by!(
  user: instructor1,
  notification_type: "new_review",
  params: { course_title: course1.title, rating: 5 }
) do |n|
  n.read_at = 1.month.ago
end

Notification.find_or_create_by!(
  user: student1,
  notification_type: "certificate_issued",
  params: { course_title: course1.title, certificate_number: cert.certificate_number }
) do |n|
  n.read_at = 3.weeks.ago
end

Notification.find_or_create_by!(
  user: instructor2,
  notification_type: "new_enrollment",
  params: { student_name: student2.name, course_title: course3.title }
)

puts "    Notifications: #{Notification.count}"

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
puts ""
puts "=== Seed Complete ==="
puts "  Users:                   #{User.count}"
puts "  Courses:                 #{Course.count} (published: #{Course.where(status: 'published').count}, draft: #{Course.where(status: 'draft').count})"
puts "  Sections:                #{Section.count}"
puts "  Lessons:                 #{Lesson.count}"
puts "  Enrollments:             #{Enrollment.count}"
puts "  LessonProgresses:        #{LessonProgress.count}"
puts "  Certificates:            #{Certificate.count}"
puts "  Reviews:                 #{Review.count}"
puts "  Notifications:           #{Notification.count}"
puts "  NotificationPreferences: #{NotificationPreference.count}"
