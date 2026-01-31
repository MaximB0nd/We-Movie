using ErrorOr;
using Microsoft.AspNetCore.Mvc;

namespace WeMovieSync.API.Extensions
{
    public static class ErrorOrExtensions
    {
        public static IActionResult ToActionResult<T>(this ErrorOr<T> result)
        {
            if (result.IsError)
            {
                var error = result.Errors.First();

                return error.Type switch
                {
                    ErrorType.Conflict => new ConflictObjectResult(error.Description),
                    ErrorType.Unauthorized => new UnauthorizedObjectResult(error.Description),
                    ErrorType.NotFound => new NotFoundObjectResult(error.Description),
                    ErrorType.Validation => new BadRequestObjectResult(error.Description),
                    _ => new ObjectResult(error.Description) { StatusCode = 500 }
                };
            }

            return new OkObjectResult(result.Value);
        }
    }
}