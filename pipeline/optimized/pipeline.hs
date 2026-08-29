import Data.Word (Word64)
import Data.Bits (xor)
import qualified Data.ByteString.Char8 as B
import qualified Data.ByteString.Builder as BB
import qualified Data.ByteString.Lazy as BL

fnvOffset :: Word64
fnvOffset = 0xcbf29ce484222325

fnvPrime :: Word64
fnvPrime = 0x100000001b3

fnv1a :: B.ByteString -> Word64
fnv1a = B.foldl' (\h c -> (h `xor` fromIntegral (fromEnum c)) * fnvPrime) fnvOffset

main :: IO ()
main = do
  let total = foldl' (\acc i -> acc + fnv1a (B.pack ("task:item:" ++ show i))) 0 [0..99999 :: Int]
  putStrLn $ "Pipeline complete: processed=100000, checksum=" ++ show total
