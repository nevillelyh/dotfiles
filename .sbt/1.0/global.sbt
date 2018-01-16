resolvers ++= Seq(
  Resolver.sonatypeRepo("public"),
  Resolver.typesafeRepo("releases"),
  "Local Maven Repository" at "file://" + Path.userHome.absolutePath + "/.m2/repository",
)

val artifactory = """"Artifactory" at "https://artifactory.spotify.net/artifactory/repo""""
addCommandAlias("artifactory", s"; set resolvers in ThisBuild += $artifactory")
