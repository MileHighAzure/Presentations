using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Web;
using StackExchange.Redis;

namespace Demo.Customer.APISvc
{
	public class RedisCacheCls
	{
  
		/// <summary>
		/// Constructor
		/// </summary>
		public RedisCacheCls()
		{	
			// Using Lazy connector approach, don't call GetDatabase() here
		}

		private static Lazy<ConnectionMultiplexer> lazyConnection = new Lazy<ConnectionMultiplexer>(() =>
		{
			// Use configuration manager for local development:
			string redisCacheConnectionString = ConfigurationManager.AppSettings.Get("RedisCacheConnectionString");
			if (string.IsNullOrEmpty(redisCacheConnectionString))
			{
				// Running in Azure, need to get Environment Variable:
				redisCacheConnectionString = Environment.GetEnvironmentVariable("RedisCacheConnectionString");
			}

			return ConnectionMultiplexer.Connect(redisCacheConnectionString);
		});

		private static ConnectionMultiplexer Connection
		{
			get
			{
				return lazyConnection.Value;
			}
		}


		/// <summary>
		/// Get Redis Cache string value by cache key
		/// </summary>
		/// <param name="cacheKey"></param>
		/// <returns></returns>
		public string GetCacheValue(string cacheKey)
		{
			// Connection refers to a property that returns a ConnectionMultiplexer
			IDatabase cache = Connection.GetDatabase();

			return cache.StringGet(cacheKey);
		}

		/// <summary>
		/// Set Redis Cache by key and store cache value
		/// </summary>
		/// <param name="cacheKey"></param>
		/// <param name="cacheValue"></param>
		public void SetCache(string cacheKey, string cacheValue)
		{

			// Connection refers to a property that returns a ConnectionMultiplexer
			IDatabase cache = Connection.GetDatabase();

			// Perform cache operations using the cache object...
			// Caching for 5 minutes
			cache.StringSet(cacheKey, cacheValue, expiry: new TimeSpan(0, 5, 0));
		}

	}
}