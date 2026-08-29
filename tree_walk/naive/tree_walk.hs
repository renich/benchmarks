import System.Directory
import System.FilePath
import Control.Monad (forM)
import qualified Data.ByteString.Char8 as B

getRecursiveContents :: FilePath -> IO [FilePath]
getRecursiveContents topdir = do
  exists <- doesDirectoryExist topdir
  if not exists
    then return []
    else do
      names <- listDirectory topdir
      paths <- forM names $ \name -> do
        let path = topdir </> name
        isDirectory <- doesDirectoryExist path
        if isDirectory
          then getRecursiveContents path
          else return (if takeExtension path == ".txt" then [path] else [])
      return (concat paths)

countMatches :: B.ByteString -> Int
countMatches bs =
  let needle = B.pack "category="
      len = B.length needle
      go acc str = case B.breakSubstring needle str of
        (_, after) -> if B.null after then acc else go (acc + 1) (B.drop len after)
  in go 0 bs

getDataDir :: IO FilePath
getDataDir = do
  e1 <- doesDirectoryExist "tree_walk/_data"
  if e1 then return "tree_walk/_data"
  else do
    e2 <- doesDirectoryExist "../../_data"
    if e2 then return "../../_data"
    else do
      e3 <- doesDirectoryExist "../_data"
      if e3 then return "../_data"
      else return "_data"

main :: IO ()
main = do
  dataDir <- getDataDir
  files <- getRecursiveContents dataDir
  contents <- mapM B.readFile files
  let total = sum (map countMatches contents)
  putStrLn $ "Tree walk complete: files=" ++ show (length files) ++ ", matches=" ++ show total
