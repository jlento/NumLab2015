-- extracturls.hs
import Text.Pandoc
import Text.Pandoc.Walk

extractURL :: Inline -> [String]
extractURL (Link _ (u,_)) = [u]
extractURL (Image _ (u,_)) = [u]
extractURL _ = []

extractURLs :: Pandoc -> [String]
extractURLs = query extractURL

readDoc :: String -> Pandoc
readDoc = readMarkdown def

main :: IO ()
main = interact (unlines . extractURLs . readDoc)
