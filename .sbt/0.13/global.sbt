resolvers ++= Seq(
  "Artifactory" at "https://artifactory.spotify.net/artifactory/repo",
  "Local Maven Repository" at "file://" + Path.userHome.absolutePath + "/.m2/repository"
)
