import 'package:app/models/models.dart';
import 'package:app/repositories/repositories.dart';
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

class ArticleLoading extends ArticleState {}

class ArticleStream extends ArticleState {
  final Stream<List<Article>> articleStream;

  ArticleStream({@required this.articleStream}) : assert(articleStream != null);
}

class ArticleBloc extends Bloc<ArticleEvent, ArticleState> {
  final ArticleRepository articleRepository;

  ArticleBloc({@required this.articleRepository})
      : assert(articleRepository != null);

  @override
  ArticleState get initialState => ArticleNotLoaded();

  @override
  Stream<ArticleState> mapEventToState(ArticleEvent event) async* {
    if (event is AllArticles) {
      yield ArticleLoading();
      articleRepository.fetch();
      yield ArticleStream(articleStream: articleRepository.articles);
    }
  }
}
