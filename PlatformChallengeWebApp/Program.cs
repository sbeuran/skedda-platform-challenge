using Microsoft.Data.SqlClient;

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/", 
    async context =>
    {
        try
        {
            var connectionString = builder.Configuration["DbConnectionString"]!;

            await using var connection = new SqlConnection(connectionString);
            connection.Open();       

            var sql = "select top 1 name from sys.all_columns";

            await using var command = new SqlCommand(sql, connection);
            await using var reader = command.ExecuteReader();
            while (reader.Read())
            {
                await context.Response.WriteAsync( $"Success! Column name is: {reader.GetString(0)}");
            }
        }
        catch (Exception e)
        {
            await context.Response.WriteAsync($"Error querying DB: {e}");
        }
    }
    );

app.Run();
