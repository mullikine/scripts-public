import System.IO
import System.Process

main = do
    {- each of these lines are statements -}

    (_, Just hout, _, _) <- createProcess (proc "date" []){ std_out = CreatePipe }
    dateOut <- hGetContents hout
    putStrLn "> date"
    putStrLn dateOut

    (Just hin, Just hout, _, _) <- createProcess (proc "grep" ["hello"]){ std_in = CreatePipe, std_out = CreatePipe }
    hPutStr hin "hello grep\ngoodbye grep"
    grepBytes <- hGetContents hout
    putStrLn "> grep hello"
    putStrLn grepBytes

    (_, Just hout, _, _) <- createProcess (proc "bash" ["-c", "ls -a -l -h"]){ std_out = CreatePipe }
    lsOut <- hGetContents hout
    putStrLn "> ls -a -l -h"
    putStrLn lsOut