publishTo <<= (organization, isSnapshot, publishTo) { (org: String, snap: Boolean, default: Option[Resolver]) =>
  if (org.startsWith("com.spotify")) {
    val prefix = "https://artifactory.spotify.net/artifactory/"
    if (snap)
      Some("snapshots" at prefix + "libs-snapshot-local;build.timestamp=" + new java.util.Date().getTime)
    else
      Some("releases"  at prefix + "libs-release-local")
  } else {
    default
  }
}
