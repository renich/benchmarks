import qualified Data.ByteString.Builder as B
import System.IO (stdout)

prefix :: B.Builder
prefix = B.string7 "Hello, this is iteration number: "

nl :: B.Builder
nl = B.char7 '\n'

buildLoop :: Int -> B.Builder
buildLoop 1000000 = mempty
buildLoop n = prefix <> B.intDec n <> nl <> buildLoop (n + 1)

main :: IO ()
main = B.hPutBuilder stdout (buildLoop 0)
