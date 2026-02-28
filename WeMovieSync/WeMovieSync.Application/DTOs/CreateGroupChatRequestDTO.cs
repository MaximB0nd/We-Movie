namespace WeMovieSync.Application.DTOs
{
    public class CreateRoomRequestDTO
    {
        public string Name { get; set; } = null!;
        public long token { get; set; } 
        //public List<long> InitialMemberIds { get; set; } = new();
    }
}
