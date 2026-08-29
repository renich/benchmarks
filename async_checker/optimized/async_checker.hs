import Data.Word (Word32, Word64)
import Data.List (sort)

runTask :: Int -> (Int, Int)
runTask tid =
  let seed :: Word64
      seed = (fromIntegral tid * 1664525 + 1013904223) `rem` 4294967296
      latency = fromIntegral (10 + (seed `rem` 990))
      status = if seed `rem` 7 /= 0
                 then 200
                 else if seed `rem` 3 == 0 then 429 else 500
  in (latency, status)

main :: IO ()
main = do
  let tasks = 10000 :: Int
      results = map runTask [0..tasks-1]
      latencies = sort (map fst results)
      totalLat = sum (map fromIntegral (map fst results)) :: Word64
      okCount = length (filter (\(_, s) -> s == 200) results)
      rlCount = length (filter (\(_, s) -> s == 429) results)
      errCount = length (filter (\(_, s) -> s == 500) results)
      p50 = latencies !! floor (fromIntegral tasks * (0.50 :: Double))
      p95 = latencies !! floor (fromIntegral tasks * (0.95 :: Double))
      p99 = latencies !! floor (fromIntegral tasks * (0.99 :: Double))

  putStrLn $ "Async complete: tasks=" ++ show tasks
          ++ ", ok=" ++ show okCount
          ++ ", rate_limited=" ++ show rlCount
          ++ ", errors=" ++ show errCount
          ++ ", latency_sum=" ++ show totalLat
          ++ ", p50=" ++ show p50
          ++ ", p95=" ++ show p95
          ++ ", p99=" ++ show p99
