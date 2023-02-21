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
    public class PeopleController : Controller
    {
        // GET: PeopleController/id
        public async Task<IActionResult> Index(int id)
        {
            People people = new People();
            try
            {
                if (id == 0)
                    return View("Text", "You must specify an ID");
                else
                {
                    Debug.Print("Looking for id " + id.ToString() + " in database");
                    using (SqlConnection oConecction = new SqlConnection(Connection.connectionLocalStorage))
                    {
                        SqlCommand cmd = new SqlCommand("[peopleById]", oConecction);
                        cmd.CommandType = System.Data.CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@id", id);

                        oConecction.Open();
                        cmd.ExecuteNonQuery();

                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (dr.HasRows)
                            {
                                dr.Read();
                                people.name = dr["name"].ToString();
                                people.birth_year = dr["birth_year"].ToString();
                                people.eye_color = dr["eye_color"].ToString();
                                people.gender = dr["gender"].ToString();
                                people.hair_color = dr["hair_color"].ToString();
                                people.height = dr["height"].ToString();
                                people.homeworld = dr["homeworld"].ToString();
                                people.mass = dr["mass"].ToString();
                                people.skin_color = dr["skin_color"].ToString();
                                people.created = dr["created"].ToString();
                                people.edited = dr["edited"].ToString();
                                people.url = dr["url"].ToString();
                            }
                            else
                            {
                                // id isn't in db, querying api
                                string url = "https://swapi.dev/api/people/" + id.ToString();
                                
                                Debug.Print("Loading url for nonchaed id:" + url);
                                using (var httpClient = new HttpClient())
                                {
                                    using (var response = await httpClient.GetAsync(url))
                                    {
                                        
                                        string apiResponse = await response.Content.ReadAsStringAsync();
                                        if (response.StatusCode == System.Net.HttpStatusCode.OK)
                                            people = JsonConvert.DeserializeObject<People>(apiResponse);
                                        else
                                            return View("Text", "Error queriying the people api, id not found");
                                    }
                                }
                            }
                        }
                    }
                }
                if (people is null)
                {
                    return View("Text", "The people Id wasnt found in the api");
                }
                return View("Detail", people);
            }
            catch (Exception ex)
            {
                return View("Text", "Error in people controller: " + ex.Message.ToString());
            }
        }
        // GET: GetPeopleWithLimit/int limit
        public async Task<IActionResult> GetPeopleWithLimit(int limit)
        {
            Peoples peoples = new Peoples();
            bool keepLoading = true;
            string url = "https://swapi.dev/api/people";
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
                            peoples = JsonConvert.DeserializeObject<Peoples>(apiResponse);

                            foreach (People people in peoples.results)
                            {
                                Debug.Print("Inserting people " + people.name);
                                using (SqlConnection oConecction = new SqlConnection(Connection.connectionLocalStorage))
                                {
                                    SqlCommand cmd = new SqlCommand("[addPeople]", oConecction);
                                    cmd.CommandType = System.Data.CommandType.StoredProcedure;
                                    cmd.Parameters.AddWithValue("@name", people.name);
                                    cmd.Parameters.AddWithValue("@birth_year", people.birth_year);
                                    cmd.Parameters.AddWithValue("@eye_color", people.eye_color);
                                    cmd.Parameters.AddWithValue("@gender", people.gender);
                                    cmd.Parameters.AddWithValue("@hair_color", people.hair_color);
                                    cmd.Parameters.AddWithValue("@height ", people.height);
                                    cmd.Parameters.AddWithValue("@homeworld ", people.homeworld);
                                    cmd.Parameters.AddWithValue("@mass ", people.mass);
                                    cmd.Parameters.AddWithValue("@skin_color ", people.skin_color);
                                    cmd.Parameters.AddWithValue("@created ", people.created);
                                    cmd.Parameters.AddWithValue("@edited ", people.edited);
                                    cmd.Parameters.AddWithValue("@url ", people.url);
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
                            if (peoples.next is null)
                                keepLoading = false;
                            else
                            {
                                url = peoples.next;
                            }
                        }
                    }
                }
                return View("Text", added.ToString() + " peoples were added to the cache");
            }
            catch(Exception ex)
            {
                return View("Text", "Error in GetPeopleWithLimit: " + ex.Message.ToString());
            }
        }
    }
}
