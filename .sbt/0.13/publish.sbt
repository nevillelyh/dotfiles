publishTo <<= (organization, name, isSnapshot, publishTo) { (org: String, name: String, snap: Boolean, default: Option[Resolver]) =>
  def isPublic(name: String): Boolean = Seq("ratatool", "scio", "spark-bigquery").exists(name.startsWith(_))

  if (org.startsWith("com.spotify") && !isPublic(name)) {
    val prefix = "https://artifactory.spotify.net/artifactory/"
    if (snap)
      Some("snapshots" at prefix + "libs-snapshot-local;build.timestamp=" + new java.util.Date().getTime)
    else
      Some("releases"  at prefix + "libs-release-local")
  } else {
    default
  }
}
