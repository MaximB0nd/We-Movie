namespace WeMovieSync.Application.DTOs
{
    public class CreateGroupChatRequestDTO
    {
        public string Name { get; set; } = null!;
        public List<long> InitialMemberIds { get; set; } = new();
    }
}
