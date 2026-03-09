# frozen_string_literal: true

require "rails_helper"

RSpec.configure do |config|
  config.openapi_root = Rails.root.join("openapi").to_s
  config.openapi_format = :yaml

  config.openapi_specs = {
    "v1/openapi.yaml" => {
      openapi: "3.0.3",
      info: {
        title: "LMS API",
        version: "v1",
        description: "オンライン学習プラットフォーム API"
      },
      servers: [
        {
          url: "http://localhost:3000",
          description: "Development"
        }
      ],
      tags: [
        { name: "Auth", description: "認証" },
        { name: "Users", description: "ユーザー" },
        { name: "Courses", description: "コース" },
        { name: "Sections", description: "セクション" },
        { name: "Lessons", description: "レッスン" },
        { name: "Enrollments", description: "受講登録" },
        { name: "LessonProgresses", description: "レッスン進捗" },
        { name: "Certificates", description: "修了証" },
        { name: "Reviews", description: "レビュー" },
        { name: "Notifications", description: "通知" },
        { name: "Admin", description: "管理者" }
      ],
      components: {
        securitySchemes: {
          bearer_auth: {
            type: :http,
            scheme: :bearer,
            bearerFormat: "JWT"
          }
        },
        schemas: {
          # ===== エラー =====
          error_response: {
            type: :object,
            properties: {
              error: {
                type: :object,
                properties: {
                  code: { type: :string, description: "エラーコード" },
                  message: { type: :string, description: "エラーメッセージ" },
                  details: {
                    type: :array,
                    nullable: true,
                    items: {
                      type: :object,
                      properties: {
                        field: { type: :string },
                        message: { type: :string }
                      },
                      required: %w[field message]
                    },
                    description: "バリデーションエラー詳細"
                  }
                },
                required: %w[code message]
              }
            },
            required: %w[error]
          },

          # ===== ページネーション =====
          pagination_meta: {
            type: :object,
            properties: {
              current_page: { type: :integer },
              total_pages: { type: :integer },
              total_count: { type: :integer },
              per_page: { type: :integer }
            },
            required: %w[current_page total_pages total_count per_page]
          },

          # ===== ユーザー =====
          user: {
            type: :object,
            properties: {
              id: { type: :integer },
              email: { type: :string, format: "email" },
              name: { type: :string },
              role: { type: :string, enum: %w[admin instructor student] },
              created_at: { type: :string, format: "date-time" }
            },
            required: %w[id email name role created_at]
          },

          # ===== コース =====
          course: {
            type: :object,
            properties: {
              id: { type: :integer },
              title: { type: :string },
              description: { type: :string, nullable: true },
              category: { type: :string, nullable: true },
              difficulty: { type: :string, nullable: true },
              max_enrollment: { type: :integer, nullable: true },
              status: { type: :string, enum: %w[draft under_review published rejected] },
              archived: { type: :boolean },
              created_at: { type: :string, format: "date-time" },
              updated_at: { type: :string, format: "date-time" },
              instructor: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  name: { type: :string }
                },
                required: %w[id name]
              },
              enrollment_count: { type: :integer },
              average_rating: { type: :number, nullable: true }
            },
            required: %w[id title status archived]
          },

          course_detail: {
            type: :object,
            properties: {
              id: { type: :integer },
              title: { type: :string },
              description: { type: :string, nullable: true },
              category: { type: :string, nullable: true },
              difficulty: { type: :string, nullable: true },
              max_enrollment: { type: :integer, nullable: true },
              status: { type: :string, enum: %w[draft under_review published rejected] },
              archived: { type: :boolean },
              created_at: { type: :string, format: "date-time" },
              updated_at: { type: :string, format: "date-time" },
              instructor: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  name: { type: :string }
                },
                required: %w[id name]
              },
              enrollment_count: { type: :integer },
              average_rating: { type: :number, nullable: true },
              sections: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    id: { type: :integer },
                    title: { type: :string },
                    position: { type: :integer },
                    lessons: {
                      type: :array,
                      items: {
                        type: :object,
                        properties: {
                          id: { type: :integer },
                          title: { type: :string },
                          content_type: { type: :string },
                          duration_minutes: { type: :integer },
                          position: { type: :integer }
                        }
                      }
                    }
                  }
                }
              },
              total_duration_minutes: { type: :integer },
              total_lessons: { type: :integer }
            },
            required: %w[id title status archived]
          },

          course_instructor: {
            type: :object,
            properties: {
              id: { type: :integer },
              title: { type: :string },
              description: { type: :string, nullable: true },
              category: { type: :string, nullable: true },
              difficulty: { type: :string, nullable: true },
              max_enrollment: { type: :integer, nullable: true },
              status: { type: :string, enum: %w[draft under_review published rejected] },
              archived: { type: :boolean },
              created_at: { type: :string, format: "date-time" },
              updated_at: { type: :string, format: "date-time" },
              enrollment_count: { type: :integer },
              active_enrollment_count: { type: :integer },
              completed_enrollment_count: { type: :integer },
              average_rating: { type: :number, nullable: true },
              review_count: { type: :integer }
            },
            required: %w[id title status archived]
          },

          course_create_params: {
            type: :object,
            properties: {
              course: {
                type: :object,
                properties: {
                  title: { type: :string },
                  description: { type: :string },
                  category: { type: :string },
                  difficulty: { type: :string },
                  max_enrollment: { type: :integer }
                },
                required: %w[title]
              }
            },
            required: %w[course]
          },

          # ===== セクション =====
          section: {
            type: :object,
            properties: {
              id: { type: :integer },
              title: { type: :string },
              position: { type: :integer },
              course_id: { type: :integer },
              created_at: { type: :string, format: "date-time" },
              updated_at: { type: :string, format: "date-time" },
              lessons: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    id: { type: :integer },
                    title: { type: :string },
                    content_type: { type: :string },
                    content_body: { type: :string, nullable: true },
                    duration_minutes: { type: :integer },
                    position: { type: :integer }
                  }
                }
              }
            },
            required: %w[id title position course_id]
          },

          section_params: {
            type: :object,
            properties: {
              section: {
                type: :object,
                properties: {
                  title: { type: :string },
                  position: { type: :integer }
                },
                required: %w[title]
              }
            },
            required: %w[section]
          },

          # ===== レッスン =====
          lesson: {
            type: :object,
            properties: {
              id: { type: :integer },
              title: { type: :string },
              content_type: { type: :string },
              content_body: { type: :string, nullable: true },
              duration_minutes: { type: :integer },
              position: { type: :integer },
              section_id: { type: :integer },
              created_at: { type: :string, format: "date-time" },
              updated_at: { type: :string, format: "date-time" }
            },
            required: %w[id title content_type section_id]
          },

          lesson_params: {
            type: :object,
            properties: {
              lesson: {
                type: :object,
                properties: {
                  title: { type: :string },
                  content_type: { type: :string },
                  content_body: { type: :string },
                  duration_minutes: { type: :integer },
                  position: { type: :integer }
                },
                required: %w[title content_type]
              }
            },
            required: %w[lesson]
          },

          # ===== 受講登録 =====
          enrollment: {
            type: :object,
            properties: {
              id: { type: :integer },
              status: { type: :string, enum: %w[pending active completed suspended] },
              enrolled_at: { type: :string, format: "date-time", nullable: true },
              completed_at: { type: :string, format: "date-time", nullable: true },
              created_at: { type: :string, format: "date-time" },
              updated_at: { type: :string, format: "date-time" },
              user: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  name: { type: :string }
                },
                required: %w[id name]
              },
              course: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  title: { type: :string }
                },
                required: %w[id title]
              },
              progress: {
                type: :object,
                properties: {
                  total_lessons: { type: :integer },
                  completed_lessons: { type: :integer },
                  percentage: { type: :number }
                }
              }
            },
            required: %w[id status]
          },

          # ===== レッスン進捗 =====
          lesson_progress: {
            type: :object,
            properties: {
              id: { type: :integer },
              status: { type: :string },
              completed_at: { type: :string, format: "date-time", nullable: true },
              lesson: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  title: { type: :string },
                  content_type: { type: :string }
                },
                required: %w[id title content_type]
              }
            },
            required: %w[id status]
          },

          lesson_progress_params: {
            type: :object,
            properties: {
              progress: {
                type: :object,
                properties: {
                  status: { type: :string, enum: %w[not_started in_progress completed] }
                },
                required: %w[status]
              }
            },
            required: %w[progress]
          },

          # ===== 修了証 =====
          certificate: {
            type: :object,
            properties: {
              id: { type: :integer },
              certificate_number: { type: :string },
              status: { type: :string },
              issued_at: { type: :string, format: "date-time", nullable: true },
              created_at: { type: :string, format: "date-time" },
              course: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  title: { type: :string }
                },
                required: %w[id title]
              },
              user: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  name: { type: :string }
                },
                required: %w[id name]
              }
            },
            required: %w[id certificate_number status]
          },

          # ===== レビュー =====
          review: {
            type: :object,
            properties: {
              id: { type: :integer },
              rating: { type: :integer, minimum: 1, maximum: 5 },
              comment: { type: :string, nullable: true },
              anonymous: { type: :boolean },
              created_at: { type: :string, format: "date-time" },
              updated_at: { type: :string, format: "date-time" },
              user: {
                type: :object,
                properties: {
                  id: { type: :integer, nullable: true },
                  name: { type: :string }
                }
              },
              course: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  title: { type: :string }
                },
                required: %w[id title]
              }
            },
            required: %w[id rating anonymous]
          },

          review_params: {
            type: :object,
            properties: {
              review: {
                type: :object,
                properties: {
                  rating: { type: :integer, minimum: 1, maximum: 5 },
                  comment: { type: :string },
                  anonymous: { type: :boolean }
                },
                required: %w[rating]
              }
            },
            required: %w[review]
          },

          # ===== 通知 =====
          notification: {
            type: :object,
            properties: {
              id: { type: :integer },
              notification_type: { type: :string },
              params: { type: :object },
              read_at: { type: :string, format: "date-time", nullable: true },
              created_at: { type: :string, format: "date-time" },
              read: { type: :boolean }
            },
            required: %w[id notification_type read]
          },

          # ===== 認証 =====
          auth_tokens: {
            type: :object,
            properties: {
              access_token: { type: :string },
              refresh_token: { type: :string },
              token_type: { type: :string },
              expires_in: { type: :integer }
            },
            required: %w[access_token refresh_token token_type expires_in]
          },

          register_params: {
            type: :object,
            properties: {
              user: {
                type: :object,
                properties: {
                  email: { type: :string, format: "email" },
                  name: { type: :string },
                  password: { type: :string, minLength: 8 },
                  password_confirmation: { type: :string },
                  role: { type: :string, enum: %w[student instructor] }
                },
                required: %w[email name password password_confirmation]
              }
            },
            required: %w[user]
          },

          login_params: {
            type: :object,
            properties: {
              auth: {
                type: :object,
                properties: {
                  email: { type: :string, format: "email" },
                  password: { type: :string }
                },
                required: %w[email password]
              }
            },
            required: %w[auth]
          },

          # ===== ダッシュボード =====
          dashboard: {
            type: :object,
            properties: {
              dashboard: {
                type: :object,
                properties: {
                  users: {
                    type: :object,
                    properties: {
                      total: { type: :integer },
                      by_role: {
                        type: :object,
                        properties: {
                          admin: { type: :integer },
                          instructor: { type: :integer },
                          student: { type: :integer }
                        }
                      }
                    }
                  },
                  courses: {
                    type: :object,
                    properties: {
                      total: { type: :integer },
                      by_status: {
                        type: :object,
                        properties: {
                          draft: { type: :integer },
                          under_review: { type: :integer },
                          published: { type: :integer },
                          rejected: { type: :integer }
                        }
                      },
                      archived: { type: :integer }
                    }
                  },
                  enrollments: {
                    type: :object,
                    properties: {
                      total: { type: :integer },
                      by_status: {
                        type: :object,
                        properties: {
                          pending: { type: :integer },
                          active: { type: :integer },
                          completed: { type: :integer },
                          suspended: { type: :integer }
                        }
                      }
                    }
                  },
                  certificates: {
                    type: :object,
                    properties: {
                      total: { type: :integer },
                      issued: { type: :integer }
                    }
                  },
                  reviews: {
                    type: :object,
                    properties: {
                      total: { type: :integer },
                      average_rating: { type: :number, nullable: true }
                    }
                  }
                }
              }
            },
            required: %w[dashboard]
          }
        }
      }
    }
  }
end
