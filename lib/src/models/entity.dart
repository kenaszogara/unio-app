enum EntityType {
  MAJORS,
  UNIVERSITIES,
  VENDORS,
  SCHOLARSHIPS,
  ARTICLES,
  PLACE_TO_LIVES
}

class Entity {
  int id;
  String type;

  Entity({int id, EntityType type}) {
    this.id = id;

    switch (type) {
      case EntityType.MAJORS:
        this.type = 'majors';
        break;
      case EntityType.UNIVERSITIES:
        this.type = 'universities';
        break;
      case EntityType.VENDORS:
        this.type = 'vendors';
        break;
      case EntityType.SCHOLARSHIPS:
        this.type = 'scholarships';
        break;
      case EntityType.ARTICLES:
        this.type = 'articles';
        break;
      case EntityType.PLACE_TO_LIVES:
        this.type = 'place-to-lives';
        break;
      default:
        this.type = null;
        break;
    }
  }
}
