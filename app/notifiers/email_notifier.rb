# 将来拡張用スタブ
# ActionMailer との統合はスコープ外
class EmailNotifier < AbstractNotifier::Base
  def new_enrollment; end
  def enrollment_created; end
  def course_approved; end
  def course_rejected; end
  def certificate_issued; end
  def new_review; end
end
