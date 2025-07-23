module Telegram

struct Chat
    id::String
end

function Chat(data::AbstractDict{<:AbstractString,<:Any})
    return Chat(string(data["id"]))
end
Base.convert(::Type{Chat}, data::AbstractDict{<:AbstractString,<:Any}) = Chat(data)

struct Message
    chat::Chat
    from::Chat
    text::String
end

function Message(data::AbstractDict{<:AbstractString,<:Any})
    return Message(
        Chat(data["chat"]),
        Chat(data["from"]),
        data["text"]
    )
end
Base.convert(::Type{Message}, data::AbstractDict{<:AbstractString,<:Any}) = Message(data)

end
