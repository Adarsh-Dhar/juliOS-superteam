module Errors

abstract type APIError <: Exception end

struct InvalidPayload <: APIError
    msg::String
end

end