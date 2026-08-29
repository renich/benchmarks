showsArc :: Int -> ShowS
showsArc a = showString "Hello, this is iteration number: " . shows a

oneMillion :: Int -> IO ()
oneMillion 1000000 = return ()
oneMillion n = do
    putStrLn (showsArc n "")
    oneMillion (n + 1)

main :: IO ()
main = oneMillion 0
