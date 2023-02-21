using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.CodeAnalysis.CSharp.Syntax;
using Newtonsoft.Json;
using swapiCache.Data;
using swapiCache.Models;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Drawing;
using System.Runtime.InteropServices;

namespace swapiCache.Controllers
{
    public class PlanetController : Controller
    {
        // GET: Planet/id
        public async Task<IActionResult> Index(int id)
        {
            Planet planet = new Planet();
            try
            {
                if (id == 0)
                    return View("Text", "You must specify an ID");
                else
                {
                    Debug.Print("Looking for id " + id.ToString() + " in planets database");
                    using (SqlConnection oConecction = new SqlConnection(Connection.connectionLocalStorage))
                    {
                        SqlCommand cmd = new SqlCommand("[planetById]", oConecction);
                        cmd.CommandType = System.Data.CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@id", id);

                        oConecction.Open();
                        cmd.ExecuteNonQuery();

                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (dr.HasRows)
                            {
                                dr.Read();
                                planet.climate = dr["climate"].ToString();
                                planet.diameter = dr["diameter"].ToString();
                                planet.gravity = dr["gravity"].ToString();
                                planet.name = dr["name"].ToString();
                                planet.population = dr["population"].ToString();
                                planet.residentsString = dr["residents"].ToString();
                                planet.terrain = dr["terrain"].ToString();
                                planet.url = dr["url"].ToString();
                            }
                            else
                            {
                                // id isn't in db, querying api
                                string url = "https://swapi.dev/api/planet/" + id.ToString();

                                Debug.Print("Loading url for nonchaed planet id:" + url);
                                using (var httpClient = new HttpClient())
                                {
                                    using (var response = await httpClient.GetAsync(url))
                                    {
                                        string apiResponse = await response.Content.ReadAsStringAsync();
                                        if(response.StatusCode== System.Net.HttpStatusCode.OK)
                                            planet = JsonConvert.DeserializeObject<Planet>(apiResponse);
                                        else
                                            return View("Text", "Error querying planet api, id not found");
                                    }
                                }
                            }
                        }
                    }
                }
                if (planet is null)
                {
                    return View("Text", "The planet Id wasnt found in the api");
                }
                return View("Detail", planet);
            }
            catch (Exception ex)
            {
                return View("Text", "Error in planet controller: " + ex.Message.ToString());
            }
        }



        // GET: GetPlanetsWithLimit
        public async Task<IActionResult> GetPlanetsWithLimit(int limit)
        {
            Planets planets = new Planets();
            bool keepLoading = true;
            string url = "https://swapi.dev/api/planets";
            int added = 0;

            try
            {
                while (keepLoading)
                {
                    Debug.Print("Loading url:" + url);
                    using (var httpClient = new HttpClient())
                    {
                        using (var response = await httpClient.GetAsync(url))
                        {
                            string apiResponse = await response.Content.ReadAsStringAsync();
                            planets = JsonConvert.DeserializeObject<Planets>(apiResponse);

                            foreach (Planet planet in planets.results)
                            {
                                Debug.Print("Inserting planet " + planet.name);
                                using (SqlConnection oConecction = new SqlConnection(Connection.connectionLocalStorage))
                                {
                                    SqlCommand cmd = new SqlCommand("[addPlanet]", oConecction);
                                    cmd.CommandType = System.Data.CommandType.StoredProcedure;
                                    cmd.Parameters.AddWithValue("@climate", planet.climate);
                                    cmd.Parameters.AddWithValue("@diameter", planet.diameter);
                                    cmd.Parameters.AddWithValue("@gravity", planet.gravity);
                                    cmd.Parameters.AddWithValue("@name", planet.name);
                                    cmd.Parameters.AddWithValue("@population", planet.population);
                                    cmd.Parameters.AddWithValue("@residents", planet.residents.Count().ToString());
                                    cmd.Parameters.AddWithValue("@terrain", planet.terrain);
                                    cmd.Parameters.AddWithValue("@url", planet.url);
                                    oConecction.Open();
                                    cmd.ExecuteNonQuery();
                                    added++;

                                    if (limit != 0)
                                    {
                                        if (added == limit)
                                        {
                                            keepLoading = false;
                                            break;
                                        }
                                    }

                                }
                            }
                            if (planets.next is null)
                                keepLoading = false;
                            else
                            {
                                url = planets.next;
                            }
                        }
                    }
                }
                return View("Text", added.ToString() + " planets were added to the cache");
            }
            catch (Exception ex)
            {
                return View("Text", "Error in GetPlanetsWithLimit controller: " + ex.Message.ToString());
            }
        }
    }
}
