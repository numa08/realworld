import 'package:app/models/models.dart';
import 'package:app/repositories/repositories.dart';
import 'package:async/async.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class ArticleEvent extends Equatable {
  ArticleEvent([List props = const []]) : super(props);
}

class AllArticles extends ArticleEvent {}

abstract class ArticleState extends Equatable {
  ArticleState([List props = const []]) : super(props);
}

class ArticleNotLoaded extends ArticleState {}

class ArticleEmpty extends ArticleState {}

class ArticleLoading extends ArticleState {}

class ArticleLoaded extends ArticleState {
  final List<Article> articles;

  ArticleLoaded({@required this.articles})
      : assert(articles != null),
        super([articles]);
}

class ArticleLoadError extends ArticleState {
  final String error;

  ArticleLoadError({@required this.error})
      : assert(error != null),
        super([error]);
}

class ArticleBloc extends Bloc<ArticleEvent, ArticleState> {
  final ArticleRepository articleRepository;

  ArticleBloc({@required this.articleRepository})
      : assert(articleRepository != null);

  @override
  ArticleState get initialState => ArticleNotLoaded();

  @override
  Stream<ArticleState> mapEventToState(ArticleEvent event) {
    if (event is AllArticles) {
      var articles = articleRepository.articles;
      var state = articles.map((data) {
        if (data.isEmpty) {
          return ArticleEmpty();
        } else {
          return ArticleLoaded(articles: data);
        }
      });
      var loading = Stream.fromIterable([ArticleLoading()]);
      var stream = StreamGroup.merge([loading, state]);
      articleRepository.fetch();
      return stream;
    }
    return Stream.empty();
  }
}
