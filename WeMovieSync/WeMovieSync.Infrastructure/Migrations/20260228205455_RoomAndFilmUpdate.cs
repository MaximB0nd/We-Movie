using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace WeMovieSync.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class RoomAndFilmUpdate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "IsGroup",
                table: "Chats",
                newName: "IsWatchRoom");

            migrationBuilder.AddColumn<string>(
                name: "MediaLink",
                table: "FilmCatalog",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<long>(
                name: "CurrentFilmId",
                table: "Chats",
                type: "bigint",
                nullable: true);

            migrationBuilder.AddColumn<double>(
                name: "CurrentPositionSeconds",
                table: "Chats",
                type: "double precision",
                nullable: false,
                defaultValue: 0.0);

            migrationBuilder.AddColumn<DateTime>(
                name: "FilmStartedAt",
                table: "Chats",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<long>(
                name: "HostUserId",
                table: "Chats",
                type: "bigint",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "IsPaused",
                table: "Chats",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<float>(
                name: "PlaybackRate",
                table: "Chats",
                type: "real",
                nullable: false,
                defaultValue: 0f);

            migrationBuilder.CreateIndex(
                name: "IX_Chats_CurrentFilmId",
                table: "Chats",
                column: "CurrentFilmId");

            migrationBuilder.AddForeignKey(
                name: "FK_Chats_FilmCatalog_CurrentFilmId",
                table: "Chats",
                column: "CurrentFilmId",
                principalTable: "FilmCatalog",
                principalColumn: "Token",
                onDelete: ReferentialAction.SetNull);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Chats_FilmCatalog_CurrentFilmId",
                table: "Chats");

            migrationBuilder.DropIndex(
                name: "IX_Chats_CurrentFilmId",
                table: "Chats");

            migrationBuilder.DropColumn(
                name: "MediaLink",
                table: "FilmCatalog");

            migrationBuilder.DropColumn(
                name: "CurrentFilmId",
                table: "Chats");

            migrationBuilder.DropColumn(
                name: "CurrentPositionSeconds",
                table: "Chats");

            migrationBuilder.DropColumn(
                name: "FilmStartedAt",
                table: "Chats");

            migrationBuilder.DropColumn(
                name: "HostUserId",
                table: "Chats");

            migrationBuilder.DropColumn(
                name: "IsPaused",
                table: "Chats");

            migrationBuilder.DropColumn(
                name: "PlaybackRate",
                table: "Chats");

            migrationBuilder.RenameColumn(
                name: "IsWatchRoom",
                table: "Chats",
                newName: "IsGroup");
        }
    }
}
