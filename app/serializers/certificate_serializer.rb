class CertificateSerializer
  include Alba::Resource

  root_key :certificate

  attributes :id, :certificate_number, :status, :issued_at, :created_at

  attribute :course do |certificate|
    course = certificate.enrollment.course
    {
      id: course.id,
      title: course.title
    }
  end

  attribute :user do |certificate|
    user = certificate.enrollment.user
    {
      id: user.id,
      name: user.name
    }
  end
end
