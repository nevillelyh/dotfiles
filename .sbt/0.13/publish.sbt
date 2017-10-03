val destination = Def.setting {
  val prefix = "https://artifactory.spotify.net/artifactory/"
  val artifactory = if (isSnapshot.value)
    Some("snapshots" at prefix + "libs-snapshot-local;build.timestamp=" + new java.util.Date().getTime)
  else
    Some("releases"  at prefix + "libs-release-local")
  publishTo.value.orElse(artifactory)
}
publishTo := destination.value
